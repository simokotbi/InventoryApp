"""
Product API client for Supabase product operations.
"""

from typing import Dict, Any, List, Optional
from .base_api_client import BaseApiClient, ApiException
from core.config_manager import ConfigManager
from app_logger.log_manager import LogManager


class ProductApiClient:
    """Handles Supabase product API calls."""
    
    def __init__(self, config_manager: ConfigManager):
        """Initialize product API client."""
        self.logger = LogManager().get_logger("ProductApiClient")
        self.config_manager = config_manager
        
        if self.config_manager.has_valid_supabase_config():
            self.client = BaseApiClient(
                base_url=self.config_manager.supabase_url,
                anon_key=self.config_manager.supabase_anon_key
            )
            self.logger.info("Product API client initialized with Supabase configuration")
        else:
            self.client = None
            self.logger.warning("Product API client not initialized - invalid Supabase configuration")
    
    def is_available(self) -> bool:
        """Check if API client is available."""
        return self.client is not None
    
    def get_all_products(self, jwt_token: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get all products from Supabase."""
        if not self.is_available():
            raise ApiException(500, "Product API client not available")
        
        try:
            # Set JWT token if provided
            if jwt_token:
                self.client.set_jwt_token(jwt_token)
            
            response = self.client.get('rest/v1/products')
            
            # Response should be a list of products
            if isinstance(response, list):
                products = response
            else:
                # Handle case where response is wrapped in an object
                products = response.get('data', [])
            
            self.logger.info(f"Retrieved {len(products)} products from API")
            return products
            
        except ApiException as e:
            self.logger.error(f"Failed to get products: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error getting products: {e}")
            raise ApiException(500, str(e))
    
    def get_product_by_id(self, product_id: int, jwt_token: Optional[str] = None) -> Dict[str, Any]:
        """Get a specific product by ID."""
        if not self.is_available():
            raise ApiException(500, "Product API client not available")
        
        try:
            # Set JWT token if provided
            if jwt_token:
                self.client.set_jwt_token(jwt_token)
            
            params = {'id': f'eq.{product_id}'}
            response = self.client.get('rest/v1/products', params=params)
            
            # Response should be a list with one item
            if isinstance(response, list) and response:
                product = response[0]
            else:
                raise ApiException(404, f"Product {product_id} not found")
            
            self.logger.info(f"Retrieved product {product_id} from API")
            return product
            
        except ApiException as e:
            self.logger.error(f"Failed to get product {product_id}: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error getting product {product_id}: {e}")
            raise ApiException(500, str(e))
    
    def create_product(self, product_data: Dict[str, Any], jwt_token: str) -> Dict[str, Any]:
        """Create a new product."""
        if not self.is_available():
            raise ApiException(500, "Product API client not available")
        
        try:
            # Set JWT token for authenticated request
            self.client.set_jwt_token(jwt_token)
            
            response = self.client.post('rest/v1/products', data=product_data)
            
            self.logger.info(f"Created product: {product_data.get('name')}")
            return response
            
        except ApiException as e:
            self.logger.error(f"Failed to create product: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error creating product: {e}")
            raise ApiException(500, str(e))
    
    def update_product(self, product_id: int, product_data: Dict[str, Any], jwt_token: str) -> Dict[str, Any]:
        """Update an existing product."""
        if not self.is_available():
            raise ApiException(500, "Product API client not available")
        
        try:
            # Set JWT token for authenticated request
            self.client.set_jwt_token(jwt_token)
            
            params = {'id': f'eq.{product_id}'}
            response = self.client.put('rest/v1/products', data=product_data, params=params)
            
            self.logger.info(f"Updated product {product_id}")
            return response
            
        except ApiException as e:
            self.logger.error(f"Failed to update product {product_id}: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error updating product {product_id}: {e}")
            raise ApiException(500, str(e))
    
    def delete_product(self, product_id: int, jwt_token: str) -> Dict[str, Any]:
        """Delete a product."""
        if not self.is_available():
            raise ApiException(500, "Product API client not available")
        
        try:
            # Set JWT token for authenticated request
            self.client.set_jwt_token(jwt_token)
            
            params = {'id': f'eq.{product_id}'}
            response = self.client.delete('rest/v1/products', params=params)
            
            self.logger.info(f"Deleted product {product_id}")
            return response
            
        except ApiException as e:
            self.logger.error(f"Failed to delete product {product_id}: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Unexpected error deleting product {product_id}: {e}")
            raise ApiException(500, str(e))
    
    def test_connection(self) -> bool:
        """Test product API connection."""
        if not self.is_available():
            return False
        
        try:
            return self.client.test_connection()
        except Exception as e:
            self.logger.error(f"Connection test failed: {e}")
            return False
