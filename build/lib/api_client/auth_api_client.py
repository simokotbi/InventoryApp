"""
Authentication API client for Supabase authentication operations.
"""

from typing import Dict, Any, Optional
from .base_api_client import BaseApiClient, ApiException
from core.config_manager import ConfigManager
from app_logger.log_manager import LogManager


class AuthApiClient:
    """Handles Supabase authentication API calls."""
    
    def __init__(self, config_manager: ConfigManager):
        """Initialize authentication API client."""
        self.logger = LogManager().get_logger("AuthApiClient")
        self.config_manager = config_manager
        
        if self.config_manager.has_valid_supabase_config():
            self.client = BaseApiClient(
                base_url=self.config_manager.supabase_url,
                anon_key=self.config_manager.supabase_anon_key
            )
            self.logger.info("Auth API client initialized with Supabase configuration")
        else:
            self.client = None
            self.logger.warning("Auth API client not initialized - invalid Supabase configuration")
    
    def is_available(self) -> bool:
        """Check if API client is available."""
        return self.client is not None
    
    def sign_in(self, email: str, password: str) -> Dict[str, Any]:
        """Sign in user with email and password."""
        if not self.is_available():
            raise ApiException(500, "Auth API client not available")
        
        try:
            data = {
                "email": email,
                "password": password
            }
            
            response = self.client.post('auth/v1/token?grant_type=password', data=data)
            
            self.logger.info(f"User signed in successfully: {email}")
            return response
            
        except ApiException as e:
            self.logger.error(f"Sign in failed for {email}: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error during sign in: {e}")
            raise ApiException(500, str(e))
    
    def sign_up(self, email: str, password: str, metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Sign up new user."""
        if not self.is_available():
            raise ApiException(500, "Auth API client not available")
        
        try:
            data = {
                "email": email,
                "password": password
            }
            
            if metadata:
                data["data"] = metadata
            
            response = self.client.post('auth/v1/signup', data=data)
            
            self.logger.info(f"User signed up successfully: {email}")
            return response
            
        except ApiException as e:
            self.logger.error(f"Sign up failed for {email}: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error during sign up: {e}")
            raise ApiException(500, str(e))
    
    def refresh_token(self, refresh_token: str) -> Dict[str, Any]:
        """Refresh access token."""
        if not self.is_available():
            raise ApiException(500, "Auth API client not available")
        
        try:
            data = {
                "refresh_token": refresh_token
            }
            
            response = self.client.post('auth/v1/token?grant_type=refresh_token', data=data)
            
            self.logger.info("Token refreshed successfully")
            return response
            
        except ApiException as e:
            self.logger.error(f"Token refresh failed: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error during token refresh: {e}")
            raise ApiException(500, str(e))
    
    def sign_out(self, jwt_token: str) -> Dict[str, Any]:
        """Sign out user."""
        if not self.is_available():
            raise ApiException(500, "Auth API client not available")
        
        try:
            # Set JWT token for authenticated request
            self.client.set_jwt_token(jwt_token)
            
            response = self.client.post('auth/v1/logout')
            
            # Clear token
            self.client.clear_jwt_token()
            
            self.logger.info("User signed out successfully")
            return response
            
        except ApiException as e:
            self.logger.error(f"Sign out failed: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error during sign out: {e}")
            raise ApiException(500, str(e))
    
    def get_user(self, jwt_token: str) -> Dict[str, Any]:
        """Get current user information."""
        if not self.is_available():
            raise ApiException(500, "Auth API client not available")
        
        try:
            # Set JWT token for authenticated request
            self.client.set_jwt_token(jwt_token)
            
            response = self.client.get('auth/v1/user')
            
            self.logger.info("User information retrieved successfully")
            return response
            
        except ApiException as e:
            self.logger.error(f"Get user failed: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error getting user: {e}")
            raise ApiException(500, str(e))
    
    def test_connection(self) -> bool:
        """Test authentication API connection."""
        if not self.is_available():
            return False
        
        try:
            return self.client.test_connection()
        except Exception as e:
            self.logger.error(f"Connection test failed: {e}")
            return False
