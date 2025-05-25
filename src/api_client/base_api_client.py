"""
Base API client for Supabase REST API communication.
Handles authentication, request/response processing, and error handling.
"""

import json
from typing import Optional, Dict, Any, Union, List
import requests
from datetime import datetime, timedelta

from core.config_manager import ConfigManager


class ApiError(Exception):
    """Custom exception for API errors."""
    
    def __init__(self, message: str, status_code: Optional[int] = None, response_data: Optional[Dict] = None):
        super().__init__(message)
        self.status_code = status_code
        self.response_data = response_data


class BaseApiClient:
    """Base client for Supabase REST API operations."""
    
    def __init__(self, config_manager: ConfigManager):
        self.config_manager = config_manager
        self._access_token: Optional[str] = None
        self._refresh_token: Optional[str] = None
        self._token_expires_at: Optional[datetime] = None
        self._session = requests.Session()
        
        # Set up session headers
        self._setup_session()
    
    def _setup_session(self) -> None:
        """Set up the requests session with default headers."""
        supabase_config = self.config_manager.get_supabase_config()
        
        self._session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'apikey': supabase_config.get('anon_key', ''),
            'User-Agent': 'ChaoOffice/1.0.0'
        })
        
        # Set base URL
        self.base_url = supabase_config.get('url', '')
        if not self.base_url.endswith('/'):
            self.base_url += '/'
    
    def set_auth_token(self, access_token: str, refresh_token: Optional[str] = None, 
                      expires_in: int = 3600) -> None:
        """Set authentication tokens."""
        self._access_token = access_token
        self._refresh_token = refresh_token
        self._token_expires_at = datetime.now() + timedelta(seconds=expires_in)
        
        # Update session authorization header
        self._session.headers['Authorization'] = f'Bearer {access_token}'
    
    def clear_auth_token(self) -> None:
        """Clear authentication tokens."""
        self._access_token = None
        self._refresh_token = None
        self._token_expires_at = None
        
        # Remove authorization header
        if 'Authorization' in self._session.headers:
            del self._session.headers['Authorization']
    
    def is_token_valid(self) -> bool:
        """Check if the current token is valid and not expired."""
        if not self._access_token or not self._token_expires_at:
            return False
        
        # Check if token expires within the next 5 minutes
        buffer_time = datetime.now() + timedelta(minutes=5)
        return self._token_expires_at > buffer_time
    
    def _refresh_access_token(self) -> bool:
        """Refresh the access token using the refresh token."""
        if not self._refresh_token:
            return False
        
        try:
            response = self._session.post(
                f"{self.base_url}auth/v1/token?grant_type=refresh_token",
                json={'refresh_token': self._refresh_token}
            )
            
            if response.status_code == 200:
                token_data = response.json()
                self.set_auth_token(
                    token_data.get('access_token', ''),
                    token_data.get('refresh_token', self._refresh_token),
                    token_data.get('expires_in', 3600)
                )
                return True
            
        except Exception:
            pass
        
        return False
    
    def _ensure_valid_token(self) -> None:
        """Ensure we have a valid token, refresh if necessary."""
        if not self.is_token_valid():
            if not self._refresh_access_token():
                raise ApiError("Authentication required", 401)
    
    def _make_request(self, method: str, endpoint: str, 
                     data: Optional[Dict[str, Any]] = None,
                     params: Optional[Dict[str, Any]] = None,
                     require_auth: bool = True) -> requests.Response:
        """Make an HTTP request to the API."""
        if require_auth:
            self._ensure_valid_token()
        
        url = f"{self.base_url}{endpoint}"
        
        try:
            response = self._session.request(
                method=method,
                url=url,
                json=data,
                params=params,
                timeout=30
            )
            
            # Handle HTTP errors
            if response.status_code >= 400:
                error_data = None
                try:
                    error_data = response.json()
                except:
                    pass
                
                error_message = "API request failed"
                if error_data:
                    error_message = error_data.get('message', error_message)
                
                raise ApiError(error_message, response.status_code, error_data)
            
            return response
            
        except requests.exceptions.RequestException as e:
            raise ApiError(f"Network error: {str(e)}")
    
    def get(self, endpoint: str, params: Optional[Dict[str, Any]] = None, 
            require_auth: bool = True) -> Dict[str, Any]:
        """Make a GET request."""
        response = self._make_request('GET', endpoint, params=params, require_auth=require_auth)
        return response.json() if response.content else {}
    
    def post(self, endpoint: str, data: Optional[Dict[str, Any]] = None, 
             require_auth: bool = True) -> Dict[str, Any]:
        """Make a POST request."""
        response = self._make_request('POST', endpoint, data=data, require_auth=require_auth)
        return response.json() if response.content else {}
    
    def put(self, endpoint: str, data: Optional[Dict[str, Any]] = None, 
            require_auth: bool = True) -> Dict[str, Any]:
        """Make a PUT request."""
        response = self._make_request('PUT', endpoint, data=data, require_auth=require_auth)
        return response.json() if response.content else {}
    
    def patch(self, endpoint: str, data: Optional[Dict[str, Any]] = None, 
              require_auth: bool = True) -> Dict[str, Any]:
        """Make a PATCH request."""
        response = self._make_request('PATCH', endpoint, data=data, require_auth=require_auth)
        return response.json() if response.content else {}
    
    def delete(self, endpoint: str, require_auth: bool = True) -> Dict[str, Any]:
        """Make a DELETE request."""
        response = self._make_request('DELETE', endpoint, require_auth=require_auth)
        return response.json() if response.content else {}
    
    # Supabase-specific methods
    def select(self, table: str, columns: str = "*", filters: Optional[Dict[str, Any]] = None,
               order_by: Optional[str] = None, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Perform a SELECT query on a Supabase table."""
        params = {'select': columns}
        
        # Add filters
        if filters:
            for key, value in filters.items():
                if isinstance(value, str):
                    params[key] = f'eq.{value}'
                elif isinstance(value, (int, float)):
                    params[key] = f'eq.{value}'
                elif isinstance(value, bool):
                    params[key] = f'eq.{str(value).lower()}'
        
        # Add ordering
        if order_by:
            params['order'] = order_by
        
        # Add limit
        if limit:
            params['limit'] = limit
        
        endpoint = f"rest/v1/{table}"
        response = self.get(endpoint, params=params)
        return response if isinstance(response, list) else []
    
    def insert(self, table: str, data: Union[Dict[str, Any], List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
        """Insert data into a Supabase table."""
        endpoint = f"rest/v1/{table}"
        
        # Ensure data is a list
        if isinstance(data, dict):
            data = [data]
        
        response = self.post(endpoint, data)
        return response if isinstance(response, list) else []
    
    def update(self, table: str, data: Dict[str, Any], filters: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Update data in a Supabase table."""
        endpoint = f"rest/v1/{table}"
        
        # Add filters as query parameters
        params = {}
        for key, value in filters.items():
            params[key] = f'eq.{value}'
        
        response = self.patch(endpoint, data)
        return response if isinstance(response, list) else []
    
    def delete_records(self, table: str, filters: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Delete records from a Supabase table."""
        endpoint = f"rest/v1/{table}"
        
        # Add filters as query parameters
        params = {}
        for key, value in filters.items():
            params[key] = f'eq.{value}'
        
        response = self.delete(endpoint)
        return response if isinstance(response, list) else []
    
    def is_connected(self) -> bool:
        """Check if we can connect to the Supabase API."""
        try:
            # Try to make a simple request
            self.get("rest/v1/", require_auth=False)
            return True
        except:
            return False
