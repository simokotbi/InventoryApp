"""
Base HTTP client for Supabase API communication.
Handles JWT tokens, base URL configuration, and error parsing.
"""

import requests
from typing import Dict, Any, Optional, Union
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from app_logger.log_manager import LogManager


class BaseApiClient:
    """Generic HTTP client for Supabase API communication."""
    
    def __init__(self, base_url: str, anon_key: str, timeout: int = 30):
        """Initialize API client."""
        self.logger = LogManager().get_logger("BaseApiClient")
        self.base_url = base_url.rstrip('/')
        self.anon_key = anon_key
        self.timeout = timeout
        self._jwt_token: Optional[str] = None
        
        # Setup session with retry strategy
        self.session = requests.Session()
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
        
        # Set default headers
        self.session.headers.update({
            'apikey': self.anon_key,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def set_jwt_token(self, token: str) -> None:
        """Set JWT token for authenticated requests."""
        self._jwt_token = token
        self.session.headers.update({
            'Authorization': f'Bearer {token}'
        })
        self.logger.info("JWT token updated")
    
    def clear_jwt_token(self) -> None:
        """Clear JWT token."""
        self._jwt_token = None
        if 'Authorization' in self.session.headers:
            del self.session.headers['Authorization']
        self.logger.info("JWT token cleared")
    
    def _make_request(
        self, 
        method: str, 
        endpoint: str, 
        data: Optional[Dict[str, Any]] = None,
        params: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None
    ) -> requests.Response:
        """Make HTTP request to API."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        request_headers = {}
        if headers:
            request_headers.update(headers)
        
        try:
            self.logger.debug(f"Making {method} request to {url}")
            
            response = self.session.request(
                method=method,
                url=url,
                json=data,
                params=params,
                headers=request_headers,
                timeout=self.timeout
            )
            
            self.logger.debug(f"Response status: {response.status_code}")
            return response
            
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Request failed: {e}")
            raise
    
    def get(
        self, 
        endpoint: str, 
        params: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """Make GET request."""
        response = self._make_request('GET', endpoint, params=params, headers=headers)
        return self._handle_response(response)
    
    def post(
        self, 
        endpoint: str, 
        data: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """Make POST request."""
        response = self._make_request('POST', endpoint, data=data, headers=headers)
        return self._handle_response(response)
    
    def put(
        self, 
        endpoint: str, 
        data: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """Make PUT request."""
        response = self._make_request('PUT', endpoint, data=data, headers=headers)
        return self._handle_response(response)
    
    def delete(
        self, 
        endpoint: str,
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """Make DELETE request."""
        response = self._make_request('DELETE', endpoint, headers=headers)
        return self._handle_response(response)
    
    def _handle_response(self, response: requests.Response) -> Dict[str, Any]:
        """Handle API response and errors."""
        try:
            if response.status_code >= 400:
                error_data = response.json() if response.content else {}
                error_message = error_data.get('message', f'HTTP {response.status_code}')
                self.logger.error(f"API error {response.status_code}: {error_message}")
                
                raise ApiException(
                    status_code=response.status_code,
                    message=error_message,
                    details=error_data
                )
            
            if response.content:
                return response.json()
            else:
                return {}
                
        except ValueError as e:
            self.logger.error(f"Failed to parse response JSON: {e}")
            raise ApiException(
                status_code=response.status_code,
                message="Invalid JSON response",
                details={'raw_response': response.text}
            )
    
    def test_connection(self) -> bool:
        """Test API connection."""
        try:
            # Simple health check - this might need adjustment based on your Supabase setup
            response = self._make_request('GET', 'rest/v1/')
            return response.status_code < 400
        except Exception as e:
            self.logger.error(f"Connection test failed: {e}")
            return False


class ApiException(Exception):
    """Custom exception for API errors."""
    
    def __init__(self, status_code: int, message: str, details: Dict[str, Any] = None):
        """Initialize API exception."""
        super().__init__(message)
        self.status_code = status_code
        self.message = message
        self.details = details or {}
    
    def __str__(self) -> str:
        """String representation of exception."""
        return f"API Error {self.status_code}: {self.message}"
