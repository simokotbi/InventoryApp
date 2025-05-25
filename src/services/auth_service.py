"""
Authentication Service

Handles user authentication, session management, and security operations.
Integrates with both local and remote authentication systems.
"""
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone, timedelta
import secrets
import hashlib
from dataclasses import dataclass

from jose import JWTError, jwt
from loguru import logger

from local_db.local_db_manager import LocalDbManager
from local_db.models import User
from api_client.auth_api_client import AuthApiClient
from core.config_manager import ConfigManager
from services.business_services import ServiceResult


@dataclass
class AuthSession:
    """Represents an authenticated user session"""
    user_id: int
    username: str
    email: str
    full_name: str
    role: str
    token: Optional[str] = None
    expires_at: Optional[datetime] = None
    permissions: Dict[str, List[str]] = None


class AuthService:
    """
    Centralized authentication service supporting both local and remote auth.
    
    Features:
    - Local password-based authentication
    - Remote JWT token authentication
    - Session management
    - Role-based permissions
    - Token refresh and validation
    """

    def __init__(
        self, 
        local_db: LocalDbManager, 
        auth_api_client: AuthApiClient,
        config_manager: ConfigManager
    ):
        self.local_db = local_db
        self.auth_api = auth_api_client
        self.config = config_manager
        self.current_session: Optional[AuthSession] = None
        
        # JWT configuration
        self.jwt_secret = self.config.get_setting("jwt_secret", self._generate_jwt_secret())
        self.jwt_algorithm = "HS256"
        self.token_expiry_hours = 8
        
        # Session storage for active sessions
        self.active_sessions: Dict[str, AuthSession] = {}

    def _generate_jwt_secret(self) -> str:
        """Generate a secure JWT secret key"""
        secret = secrets.token_urlsafe(32)
        self.config.update_setting("jwt_secret", secret)
        return secret

    async def login(
        self, 
        username: str, 
        password: str, 
        remember_me: bool = False,
        use_remote: bool = True
    ) -> ServiceResult:
        """
        Authenticate user credentials and create session.
        
        Args:
            username: Username or email
            password: User password
            remember_me: Whether to create a persistent session
            use_remote: Whether to try remote authentication first
            
        Returns:
            ServiceResult with session data
        """
        try:
            logger.info(f"Login attempt for user: {username}")
            
            # Try remote authentication first if available
            if use_remote and self.config.get_setting("use_remote_auth", False):
                remote_result = await self._remote_login(username, password)
                if remote_result.success:
                    return remote_result
                else:
                    logger.warning(f"Remote login failed: {remote_result.errors}")
            
            # Fall back to local authentication
            local_result = await self._local_login(username, password)
            
            if local_result.success:
                session = local_result.data
                
                # Generate JWT token for session
                token = self._generate_jwt_token(session, remember_me)
                session.token = token
                
                # Store session
                self.current_session = session
                self.active_sessions[token] = session
                
                logger.info(f"User logged in successfully: {username}")
                
                return ServiceResult(
                    success=True,
                    data={
                        "session": session.__dict__,
                        "token": token,
                        "user": {
                            "id": session.user_id,
                            "username": session.username,
                            "email": session.email,
                            "full_name": session.full_name,
                            "role": session.role
                        }
                    },
                    message="Login successful"
                )
            else:
                logger.warning(f"Local login failed for user: {username}")
                return local_result
                
        except Exception as e:
            logger.error(f"Login error: {e}")
            return ServiceResult(False, errors=[str(e)])

    async def _remote_login(self, username: str, password: str) -> ServiceResult:
        """Authenticate against remote Supabase backend"""
        try:
            response = await self.auth_api.login(username, password)
            
            if response.get("success"):
                user_data = response.get("user", {})
                token = response.get("access_token")
                
                # Create session from remote data
                session = AuthSession(
                    user_id=user_data.get("id"),
                    username=user_data.get("username"),
                    email=user_data.get("email"),
                    full_name=user_data.get("full_name"),
                    role=user_data.get("role", "employee"),
                    token=token,
                    expires_at=datetime.now(timezone.utc) + timedelta(hours=self.token_expiry_hours)
                )
                
                # Sync user data to local database
                await self._sync_user_from_remote(user_data)
                
                return ServiceResult(True, data=session)
            else:
                return ServiceResult(False, errors=["Remote authentication failed"])
                
        except Exception as e:
            logger.error(f"Remote login error: {e}")
            return ServiceResult(False, errors=[str(e)])

    async def _local_login(self, username: str, password: str) -> ServiceResult:
        """Authenticate against local database"""
        try:
            with self.local_db.get_session() as session:
                user = session.query(User).filter(
                    (User.username == username) | (User.email == username)
                ).filter(User.is_active == True).first()
                
                if not user:
                    return ServiceResult(False, errors=["Invalid credentials"])
                
                if not user.check_password(password):
                    return ServiceResult(False, errors=["Invalid credentials"])
                
                # Update last login
                user.last_login = datetime.now(timezone.utc)
                session.commit()
                
                # Create auth session
                auth_session = AuthSession(
                    user_id=user.id,
                    username=user.username,
                    email=user.email,
                    full_name=user.full_name,
                    role=user.role,
                    expires_at=datetime.now(timezone.utc) + timedelta(hours=self.token_expiry_hours)
                )
                
                # Load permissions
                auth_session.permissions = self._get_user_permissions(user.role)
                
                return ServiceResult(True, data=auth_session)
                
        except Exception as e:
            logger.error(f"Local login error: {e}")
            return ServiceResult(False, errors=[str(e)])

    def logout(self, token: Optional[str] = None) -> ServiceResult:
        """
        Logout user and invalidate session.
        
        Args:
            token: Session token to invalidate (optional)
            
        Returns:
            ServiceResult indicating success
        """
        try:
            if token and token in self.active_sessions:
                del self.active_sessions[token]
                logger.info("Token session invalidated")
            
            if self.current_session:
                username = self.current_session.username
                self.current_session = None
                logger.info(f"User logged out: {username}")
            
            return ServiceResult(True, message="Logout successful")
            
        except Exception as e:
            logger.error(f"Logout error: {e}")
            return ServiceResult(False, errors=[str(e)])

    def validate_token(self, token: str) -> ServiceResult:
        """
        Validate JWT token and return session data.
        
        Args:
            token: JWT token to validate
            
        Returns:
            ServiceResult with session data if valid
        """
        try:
            # Check if token exists in active sessions
            if token in self.active_sessions:
                session = self.active_sessions[token]
                
                # Check if session is expired
                if session.expires_at and session.expires_at < datetime.now(timezone.utc):
                    del self.active_sessions[token]
                    return ServiceResult(False, errors=["Token expired"])
                
                return ServiceResult(True, data=session)
            
            # Validate JWT token
            try:
                payload = jwt.decode(token, self.jwt_secret, algorithms=[self.jwt_algorithm])
                user_id = payload.get("user_id")
                username = payload.get("username")
                exp = payload.get("exp")
                
                if not user_id or not username:
                    return ServiceResult(False, errors=["Invalid token"])
                
                # Check expiration
                if exp and datetime.fromtimestamp(exp, timezone.utc) < datetime.now(timezone.utc):
                    return ServiceResult(False, errors=["Token expired"])
                
                # Get user data from database
                user = self.local_db.get_user_by_id(user_id)
                if not user or not user.is_active:
                    return ServiceResult(False, errors=["User not found or inactive"])
                
                # Create session
                session = AuthSession(
                    user_id=user.id,
                    username=user.username,
                    email=user.email,
                    full_name=user.full_name,
                    role=user.role,
                    token=token,
                    expires_at=datetime.fromtimestamp(exp, timezone.utc) if exp else None,
                    permissions=self._get_user_permissions(user.role)
                )
                
                # Store in active sessions
                self.active_sessions[token] = session
                
                return ServiceResult(True, data=session)
                
            except JWTError as e:
                logger.warning(f"JWT validation error: {e}")
                return ServiceResult(False, errors=["Invalid token"])
                
        except Exception as e:
            logger.error(f"Token validation error: {e}")
            return ServiceResult(False, errors=[str(e)])

    def refresh_token(self, current_token: str) -> ServiceResult:
        """
        Refresh an existing JWT token.
        
        Args:
            current_token: Current JWT token
            
        Returns:
            ServiceResult with new token
        """
        try:
            validation_result = self.validate_token(current_token)
            
            if not validation_result.success:
                return validation_result
            
            session = validation_result.data
            
            # Generate new token
            new_token = self._generate_jwt_token(session, remember_me=True)
            
            # Update session
            session.token = new_token
            session.expires_at = datetime.now(timezone.utc) + timedelta(hours=self.token_expiry_hours)
            
            # Remove old token and add new one
            if current_token in self.active_sessions:
                del self.active_sessions[current_token]
            self.active_sessions[new_token] = session
            
            logger.info(f"Token refreshed for user: {session.username}")
            
            return ServiceResult(
                True,
                data={"token": new_token, "expires_at": session.expires_at},
                message="Token refreshed successfully"
            )
            
        except Exception as e:
            logger.error(f"Token refresh error: {e}")
            return ServiceResult(False, errors=[str(e)])

    def get_current_user(self) -> Optional[AuthSession]:
        """Get the current authenticated user session"""
        return self.current_session

    def check_permission(self, resource: str, action: str) -> bool:
        """
        Check if current user has permission for a specific action.
        
        Args:
            resource: Resource name (e.g., 'products', 'users')
            action: Action name (e.g., 'create', 'read', 'update', 'delete')
            
        Returns:
            bool: True if user has permission
        """
        if not self.current_session:
            return False
        
        permissions = self.current_session.permissions or {}
        resource_permissions = permissions.get(resource, [])
        
        return action in resource_permissions

    def require_permission(self, resource: str, action: str) -> ServiceResult:
        """
        Require specific permission, return error if not authorized.
        
        Args:
            resource: Resource name
            action: Action name
            
        Returns:
            ServiceResult indicating authorization status
        """
        if not self.current_session:
            return ServiceResult(False, errors=["Not authenticated"])
        
        if not self.check_permission(resource, action):
            return ServiceResult(
                False, 
                errors=[f"Insufficient permissions for {action} on {resource}"]
            )
        
        return ServiceResult(True)

    def _generate_jwt_token(self, session: AuthSession, remember_me: bool = False) -> str:
        """Generate JWT token for session"""
        try:
            expiry_hours = 24 * 7 if remember_me else self.token_expiry_hours  # 7 days vs 8 hours
            
            payload = {
                "user_id": session.user_id,
                "username": session.username,
                "role": session.role,
                "exp": datetime.now(timezone.utc) + timedelta(hours=expiry_hours),
                "iat": datetime.now(timezone.utc)
            }
            
            token = jwt.encode(payload, self.jwt_secret, algorithm=self.jwt_algorithm)
            return token
            
        except Exception as e:
            logger.error(f"JWT generation error: {e}")
            raise

    def _get_user_permissions(self, role: str) -> Dict[str, List[str]]:
        """Get permissions for a user role"""
        permissions = {
            "admin": {
                "users": ["create", "read", "update", "delete"],
                "products": ["create", "read", "update", "delete"],
                "customers": ["create", "read", "update", "delete"],
                "sales": ["create", "read", "update", "delete"],
                "inventory": ["create", "read", "update", "delete"],
                "reports": ["read"],
                "settings": ["read", "update"]
            },
            "manager": {
                "users": ["read"],
                "products": ["create", "read", "update"],
                "customers": ["create", "read", "update"],
                "sales": ["create", "read", "update"],
                "inventory": ["read", "update"],
                "reports": ["read"],
                "settings": ["read"]
            },
            "employee": {
                "products": ["read"],
                "customers": ["create", "read", "update"],
                "sales": ["create", "read"],
                "inventory": ["read"],
                "reports": [],
                "settings": []
            }
        }
        
        return permissions.get(role, permissions["employee"])

    async def _sync_user_from_remote(self, remote_user_data: Dict[str, Any]):
        """Sync user data from remote to local database"""
        try:
            user_id = remote_user_data.get("id")
            
            with self.local_db.get_session() as session:
                local_user = session.query(User).filter(User.id == user_id).first()
                
                if local_user:
                    # Update existing user
                    for key, value in remote_user_data.items():
                        if hasattr(local_user, key) and key not in ["id", "password"]:
                            setattr(local_user, key, value)
                    
                    local_user.last_synced_at = datetime.now(timezone.utc)
                    local_user.is_synced = True
                    
                else:
                    # Create new user (without password)
                    user_data = remote_user_data.copy()
                    user_data.pop("password", None)  # Don't sync password
                    user_data["is_synced"] = True
                    user_data["last_synced_at"] = datetime.now(timezone.utc)
                    
                    new_user = User(**user_data)
                    session.add(new_user)
                
                session.commit()
                
        except Exception as e:
            logger.error(f"Error syncing user from remote: {e}")

    def cleanup_expired_sessions(self):
        """Remove expired sessions from active sessions"""
        try:
            current_time = datetime.now(timezone.utc)
            expired_tokens = []
            
            for token, session in self.active_sessions.items():
                if session.expires_at and session.expires_at < current_time:
                    expired_tokens.append(token)
            
            for token in expired_tokens:
                del self.active_sessions[token]
                logger.debug(f"Removed expired session: {token[:10]}...")
            
            if expired_tokens:
                logger.info(f"Cleaned up {len(expired_tokens)} expired sessions")
                
        except Exception as e:
            logger.error(f"Error cleaning up expired sessions: {e}")

    def get_session_info(self) -> Dict[str, Any]:
        """Get information about current authentication state"""
        return {
            "is_authenticated": self.current_session is not None,
            "current_user": self.current_session.__dict__ if self.current_session else None,
            "active_sessions_count": len(self.active_sessions),
            "jwt_algorithm": self.jwt_algorithm,
            "token_expiry_hours": self.token_expiry_hours
        }
