"""
Authentication API client for Supabase Auth operations.
Handles user sign up, sign in, sign out, and token management.
"""

from typing import Dict, Any, Optional
from .base_api_client import BaseApiClient, ApiError


class AuthApiClient:
    """Handles authentication operations with Supabase Auth."""
    
    def __init__(self, base_client: BaseApiClient):
        self.base_client = base_client
    
    def sign_up(self, email: str, password: str, user_metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Sign up a new user."""
        try:
            data = {
                'email': email,
                'password': password
            }
            
            if user_metadata:
                data['data'] = user_metadata
            
            response = self.base_client.post('auth/v1/signup', data, require_auth=False)
            return response
            
        except ApiError as e:
            if e.status_code == 422:
                # Handle common signup errors
                if e.response_data and 'msg' in e.response_data:
                    raise ApiError(e.response_data['msg'], e.status_code)
            raise
    
    def sign_in(self, email: str, password: str) -> Dict[str, Any]:
        """Sign in an existing user."""
        try:
            data = {
                'email': email,
                'password': password
            }
            
            response = self.base_client.post('auth/v1/token?grant_type=password', data, require_auth=False)
            
            # Set the tokens in the base client
            if 'access_token' in response:
                self.base_client.set_auth_token(
                    response['access_token'],
                    response.get('refresh_token'),
                    response.get('expires_in', 3600)
                )
            
            return response
            
        except ApiError as e:
            if e.status_code == 400:
                # Handle invalid credentials
                raise ApiError("Invalid email or password", e.status_code)
            raise
    
    def sign_out(self) -> Dict[str, Any]:
        """Sign out the current user."""
        try:
            response = self.base_client.post('auth/v1/logout', {})
            
            # Clear tokens from base client
            self.base_client.clear_auth_token()
            
            return response
            
        except ApiError:
            # Even if the API call fails, clear local tokens
            self.base_client.clear_auth_token()
            return {}
    
    def refresh_token(self, refresh_token: str) -> Dict[str, Any]:
        """Refresh the access token."""
        try:
            data = {
                'refresh_token': refresh_token
            }
            
            response = self.base_client.post('auth/v1/token?grant_type=refresh_token', data, require_auth=False)
            
            # Update tokens in base client
            if 'access_token' in response:
                self.base_client.set_auth_token(
                    response['access_token'],
                    response.get('refresh_token', refresh_token),
                    response.get('expires_in', 3600)
                )
            
            return response
            
        except ApiError as e:
            # If refresh fails, clear tokens
            self.base_client.clear_auth_token()
            raise
    
    def get_user(self) -> Dict[str, Any]:
        """Get the current authenticated user."""
        try:
            response = self.base_client.get('auth/v1/user')
            return response
            
        except ApiError as e:
            if e.status_code == 401:
                raise ApiError("User not authenticated", e.status_code)
            raise
    
    def update_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update the current user's profile."""
        try:
            response = self.base_client.put('auth/v1/user', user_data)
            return response
            
        except ApiError as e:
            if e.status_code == 401:
                raise ApiError("User not authenticated", e.status_code)
            raise
    
    def change_password(self, new_password: str) -> Dict[str, Any]:
        """Change the current user's password."""
        try:
            data = {'password': new_password}
            response = self.base_client.put('auth/v1/user', data)
            return response
            
        except ApiError as e:
            if e.status_code == 401:
                raise ApiError("User not authenticated", e.status_code)
            elif e.status_code == 422:
                raise ApiError("Password does not meet requirements", e.status_code)
            raise
    
    def reset_password(self, email: str) -> Dict[str, Any]:
        """Send password reset email."""
        try:
            data = {'email': email}
            response = self.base_client.post('auth/v1/recover', data, require_auth=False)
            return response
            
        except ApiError as e:
            if e.status_code == 400:
                raise ApiError("Invalid email address", e.status_code)
            raise
    
    def verify_email(self, token: str, type_: str = 'signup') -> Dict[str, Any]:
        """Verify email with token."""
        try:
            data = {
                'token': token,
                'type': type_
            }
            response = self.base_client.post('auth/v1/verify', data, require_auth=False)
            return response
            
        except ApiError as e:
            if e.status_code == 400:
                raise ApiError("Invalid or expired token", e.status_code)
            raise
    
    def is_authenticated(self) -> bool:
        """Check if user is currently authenticated."""
        return self.base_client.is_token_valid()
    
    def get_session(self) -> Optional[Dict[str, Any]]:
        """Get current session information."""
        if not self.is_authenticated():
            return None
        
        try:
            user = self.get_user()
            return {
                'user': user,
                'access_token': self.base_client._access_token,
                'refresh_token': self.base_client._refresh_token,
                'expires_at': self.base_client._token_expires_at.isoformat() if self.base_client._token_expires_at else None
            }
        except:
            return None
