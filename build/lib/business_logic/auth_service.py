"""
Authentication service - business logic layer.
Abstracts data source selection between local database and API.
"""

from typing import Dict, Any, Optional, Tuple
from local_db.local_db_manager import LocalDbManager
from api_client.auth_api_client import AuthApiClient
from api_client.base_api_client import ApiException
from core.config_manager import ConfigManager
from app_logger.log_manager import LogManager


class AuthService:
    """Authentication business logic service."""
    
    def __init__(self, config_manager: ConfigManager, db_manager: LocalDbManager, auth_api: AuthApiClient):
        """Initialize authentication service."""
        self.logger = LogManager().get_logger("AuthService")
        self.config_manager = config_manager
        self.db_manager = db_manager
        self.auth_api = auth_api
        self._current_user: Optional[Dict[str, Any]] = None
        self._jwt_token: Optional[str] = None
        self.logger.info("Authentication service initialized")
    
    def login(self, email: str, password: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """
        Authenticate user login.
        Returns: (success, message, user_data)
        """
        try:
            if self.config_manager.is_online and self.auth_api.is_available():
                return self._login_online(email, password)
            else:
                return self._login_offline(email, password)
                
        except Exception as e:
            error_msg = f"Login failed: {e}"
            self.logger.error(error_msg)
            return False, error_msg, None
    
    def _login_online(self, email: str, password: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Login using Supabase API."""
        try:
            self.logger.info(f"Attempting online login for: {email}")
            
            # Call Supabase auth API
            auth_response = self.auth_api.sign_in(email, password)
            
            # Extract user data and token
            user_data = auth_response.get('user', {})
            access_token = auth_response.get('access_token')
            
            if user_data and access_token:
                # Store authentication state
                self._current_user = {
                    'id': user_data.get('id'),
                    'email': user_data.get('email'),
                    'full_name': user_data.get('user_metadata', {}).get('full_name', ''),
                    'source': 'api'
                }
                self._jwt_token = access_token
                
                self.logger.info(f"Online login successful for: {email}")
                return True, "Login successful", self._current_user
            else:
                return False, "Invalid response from authentication server", None
                
        except ApiException as e:
            if e.status_code == 401:
                return False, "Invalid email or password", None
            else:
                return False, f"Authentication server error: {e.message}", None
        except Exception as e:
            self.logger.error(f"Online login error: {e}")
            return False, f"Login failed: {e}", None
    
    def _login_offline(self, email: str, password: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Login using local database."""
        try:
            self.logger.info(f"Attempting offline login for: {email}")
            
            # Check local database
            user = self.db_manager.get_user_by_credentials(email, password)
            
            if user:
                # Store authentication state
                self._current_user = {
                    'id': user.id,
                    'email': user.email,
                    'full_name': user.full_name or '',
                    'source': 'local'
                }
                self._jwt_token = None  # No JWT for local auth
                
                self.logger.info(f"Offline login successful for: {email}")
                return True, "Login successful", self._current_user
            else:
                return False, "Invalid email or password", None
                
        except Exception as e:
            self.logger.error(f"Offline login error: {e}")
            return False, f"Login failed: {e}", None
    
    def logout(self) -> Tuple[bool, str]:
        """
        Logout current user.
        Returns: (success, message)
        """
        try:
            user_email = self._current_user.get('email', 'unknown') if self._current_user else 'unknown'
            
            # If we have a JWT token, try to logout from API
            if self._jwt_token and self.auth_api.is_available():
                try:
                    self.auth_api.sign_out(self._jwt_token)
                    self.logger.info(f"API logout successful for: {user_email}")
                except Exception as e:
                    self.logger.warning(f"API logout failed, continuing with local logout: {e}")
            
            # Clear local authentication state
            self._current_user = None
            self._jwt_token = None
            
            self.logger.info(f"Logout successful for: {user_email}")
            return True, "Logout successful"
            
        except Exception as e:
            error_msg = f"Logout failed: {e}"
            self.logger.error(error_msg)
            return False, error_msg
    
    def is_logged_in(self) -> bool:
        """Check if user is currently logged in."""
        return self._current_user is not None
    
    def get_current_user(self) -> Optional[Dict[str, Any]]:
        """Get current user data."""
        return self._current_user
    
    def get_jwt_token(self) -> Optional[str]:
        """Get current JWT token."""
        return self._jwt_token
    
    def refresh_token(self) -> Tuple[bool, str]:
        """
        Refresh JWT token (for future implementation).
        Returns: (success, message)
        """
        if not self._jwt_token or not self.auth_api.is_available():
            return False, "No token to refresh or API not available"
        
        try:
            # This would require storing the refresh token from initial login
            # For now, just return success to maintain the interface
            self.logger.info("Token refresh requested")
            return True, "Token refresh not implemented yet"
            
        except Exception as e:
            error_msg = f"Token refresh failed: {e}"
            self.logger.error(error_msg)
            return False, error_msg
    
    def create_account(self, email: str, password: str, full_name: str = "") -> Tuple[bool, str]:
        """
        Create new user account.
        Returns: (success, message)
        """
        try:
            if self.config_manager.is_online and self.auth_api.is_available():
                return self._create_account_online(email, password, full_name)
            else:
                return self._create_account_offline(email, password, full_name)
                
        except Exception as e:
            error_msg = f"Account creation failed: {e}"
            self.logger.error(error_msg)
            return False, error_msg
    
    def _create_account_online(self, email: str, password: str, full_name: str) -> Tuple[bool, str]:
        """Create account using Supabase API."""
        try:
            metadata = {'full_name': full_name} if full_name else None
            self.auth_api.sign_up(email, password, metadata)
            
            self.logger.info(f"Online account created for: {email}")
            return True, "Account created successfully"
            
        except ApiException as e:
            if e.status_code == 422:
                return False, "Email already registered"
            else:
                return False, f"Account creation failed: {e.message}"
        except Exception as e:
            self.logger.error(f"Online account creation error: {e}")
            return False, f"Account creation failed: {e}"
    
    def _create_account_offline(self, email: str, password: str, full_name: str) -> Tuple[bool, str]:
        """Create account in local database."""
        try:
            user = self.db_manager.create_user(email, password, full_name)
            
            if user:
                self.logger.info(f"Offline account created for: {email}")
                return True, "Account created successfully"
            else:
                return False, "Email already registered"
                
        except Exception as e:
            self.logger.error(f"Offline account creation error: {e}")
            return False, f"Account creation failed: {e}"
