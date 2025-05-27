"""
Product service - business logic layer.
Abstracts data source selection between local database and API.
"""

from typing import List, Dict, Any, Optional, Tuple
from local_db.local_db_manager import LocalDbManager
from api_client.product_api_client import ProductApiClient
from api_client.base_api_client import ApiException
from core.config_manager import ConfigManager
from app_logger.log_manager import LogManager


class ProductService:
    """Product business logic service."""
    
    def __init__(self, config_manager: ConfigManager, db_manager: LocalDbManager, product_api: ProductApiClient):
        """Initialize product service."""
        self.logger = LogManager().get_logger("ProductService")
        self.config_manager = config_manager
        self.db_manager = db_manager
        self.product_api = product_api
        self.logger.info("Product service initialized")
    
    def get_products(self, jwt_token: Optional[str] = None) -> Tuple[bool, str, List[Dict[str, Any]]]:
        """
        Get all products.
        Returns: (success, message, products_list)
        """
        try:
            if self.config_manager.is_online and self.product_api.is_available():
                return self._get_products_online(jwt_token)
            else:
                return self._get_products_offline()
                
        except Exception as e:
            error_msg = f"Failed to get products: {e}"
            self.logger.error(error_msg)
            return False, error_msg, []
    
    def _get_products_online(self, jwt_token: Optional[str] = None) -> Tuple[bool, str, List[Dict[str, Any]]]:
        """Get products from Supabase API."""
        try:
            self.logger.info("Fetching products from API")
            
            # Get products from API
            api_products = self.product_api.get_all_products(jwt_token)
            
            # Convert to consistent format
            products = []
            for api_product in api_products:
                # Handle price formatting
                price = api_product.get('price', 0)
                if isinstance(price, (int, float)):
                    if isinstance(price, float) or (isinstance(price, int) and price < 1000):
                        formatted_price = f"${price:.2f}"
                        price_cents = int(price * 100)
                    else:
                        formatted_price = f"${price / 100:.2f}"
                        price_cents = price
                else:
                    formatted_price = "$0.00"
                    price_cents = 0
                
                product = {
                    'id': api_product.get('id'),
                    'name': api_product.get('name', ''),
                    'description': api_product.get('description', ''),
                    'price': price_cents,
                    'formatted_price': formatted_price,
                    'sku': api_product.get('sku', ''),
                    'category': api_product.get('category', ''),
                    'stock_quantity': api_product.get('stock_quantity', 0),
                    'source': 'api'
                }
                products.append(product)
            
            self.logger.info(f"Retrieved {len(products)} products from API")
            return True, f"Retrieved {len(products)} products", products
            
        except ApiException as e:
            error_msg = f"API error getting products: {e.message}"
            self.logger.error(error_msg)
            return False, error_msg, []
        except Exception as e:
            error_msg = f"Error getting products from API: {e}"
            self.logger.error(error_msg)
            return False, error_msg, []
    
    def _get_products_offline(self) -> Tuple[bool, str, List[Dict[str, Any]]]:
        """Get products from local database."""
        try:
            self.logger.info("Fetching products from local database")
            
            # Get products from local database
            local_products = self.db_manager.get_all_products()
            
            # Convert to consistent format
            products = []
            for product in local_products:
                product_dict = product.to_dict()
                product_dict['source'] = 'local'
                products.append(product_dict)
            
            self.logger.info(f"Retrieved {len(products)} products from local database")
            return True, f"Retrieved {len(products)} products", products
            
        except Exception as e:
            error_msg = f"Error getting products from local database: {e}"
            self.logger.error(error_msg)
            return False, error_msg, []
    
    def get_product_by_id(self, product_id: int, jwt_token: Optional[str] = None) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """
        Get a specific product by ID.
        Returns: (success, message, product_data)
        """
        try:
            if self.config_manager.is_online and self.product_api.is_available():
                return self._get_product_by_id_online(product_id, jwt_token)
            else:
                return self._get_product_by_id_offline(product_id)
                
        except Exception as e:
            error_msg = f"Failed to get product {product_id}: {e}"
            self.logger.error(error_msg)
            return False, error_msg, None
    
    def _get_product_by_id_online(self, product_id: int, jwt_token: Optional[str] = None) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Get product from API."""
        try:
            api_product = self.product_api.get_product_by_id(product_id, jwt_token)
            
            # Convert to consistent format (similar to _get_products_online)
            price = api_product.get('price', 0)
            if isinstance(price, (int, float)):
                if isinstance(price, float) or (isinstance(price, int) and price < 1000):
                    formatted_price = f"${price:.2f}"
                    price_cents = int(price * 100)
                else:
                    formatted_price = f"${price / 100:.2f}"
                    price_cents = price
            else:
                formatted_price = "$0.00"
                price_cents = 0
            
            product = {
                'id': api_product.get('id'),
                'name': api_product.get('name', ''),
                'description': api_product.get('description', ''),
                'price': price_cents,
                'formatted_price': formatted_price,
                'sku': api_product.get('sku', ''),
                'category': api_product.get('category', ''),
                'stock_quantity': api_product.get('stock_quantity', 0),
                'source': 'api'
            }
            
            return True, "Product retrieved", product
            
        except ApiException as e:
            if e.status_code == 404:
                return False, f"Product {product_id} not found", None
            else:
                return False, f"API error: {e.message}", None
        except Exception as e:
            return False, f"Error getting product: {e}", None
    
    def _get_product_by_id_offline(self, product_id: int) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Get product from local database."""
        try:
            product = self.db_manager.get_product_by_id(product_id)
            
            if product:
                product_dict = product.to_dict()
                product_dict['source'] = 'local'
                return True, "Product retrieved", product_dict
            else:
                return False, f"Product {product_id} not found", None
                
        except Exception as e:
            return False, f"Error getting product: {e}", None
    
    def create_product(self, product_data: Dict[str, Any], jwt_token: Optional[str] = None) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """
        Create a new product.
        Returns: (success, message, created_product_data)
        """
        try:
            if self.config_manager.is_online and self.product_api.is_available() and jwt_token:
                return self._create_product_online(product_data, jwt_token)
            else:
                return self._create_product_offline(product_data)
                
        except Exception as e:
            error_msg = f"Failed to create product: {e}"
            self.logger.error(error_msg)
            return False, error_msg, None
    
    def _create_product_online(self, product_data: Dict[str, Any], jwt_token: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Create product via API."""
        try:
            created_product = self.product_api.create_product(product_data, jwt_token)
            self.logger.info(f"Product created via API: {product_data.get('name')}")
            return True, "Product created successfully", created_product
            
        except ApiException as e:
            return False, f"API error: {e.message}", None
        except Exception as e:
            return False, f"Error creating product: {e}", None
    
    def _create_product_offline(self, product_data: Dict[str, Any]) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Create product in local database."""
        try:
            product = self.db_manager.create_product(
                name=product_data.get('name', ''),
                description=product_data.get('description', ''),
                price=product_data.get('price', 0),
                sku=product_data.get('sku', ''),
                category=product_data.get('category', ''),
                stock_quantity=product_data.get('stock_quantity', 0)
            )
            
            if product:
                product_dict = product.to_dict()
                product_dict['source'] = 'local'
                self.logger.info(f"Product created locally: {product_data.get('name')}")
                return True, "Product created successfully", product_dict
            else:
                return False, "Failed to create product", None
                
        except Exception as e:
            return False, f"Error creating product: {e}", None
    
    def search_products(self, query: str, jwt_token: Optional[str] = None) -> Tuple[bool, str, List[Dict[str, Any]]]:
        """
        Search products by name or description.
        Returns: (success, message, matching_products)
        """
        try:
            # Get all products first
            success, message, all_products = self.get_products(jwt_token)
            
            if not success:
                return success, message, []
            
            # Simple text search
            query_lower = query.lower()
            matching_products = []
            
            for product in all_products:
                name = product.get('name', '').lower()
                description = product.get('description', '').lower()
                category = product.get('category', '').lower()
                sku = product.get('sku', '').lower()
                
                if (query_lower in name or 
                    query_lower in description or 
                    query_lower in category or 
                    query_lower in sku):
                    matching_products.append(product)
            
            self.logger.info(f"Search for '{query}' returned {len(matching_products)} results")
            return True, f"Found {len(matching_products)} matching products", matching_products
            
        except Exception as e:
            error_msg = f"Product search failed: {e}"
            self.logger.error(error_msg)
            return False, error_msg, []
    
    def get_products_by_category(self, category: str, jwt_token: Optional[str] = None) -> Tuple[bool, str, List[Dict[str, Any]]]:
        """
        Get products by category.
        Returns: (success, message, category_products)
        """
        try:
            # Get all products first
            success, message, all_products = self.get_products(jwt_token)
            
            if not success:
                return success, message, []
            
            # Filter by category
            category_products = [
                product for product in all_products 
                if product.get('category', '').lower() == category.lower()
            ]
            
            self.logger.info(f"Category '{category}' has {len(category_products)} products")
            return True, f"Found {len(category_products)} products in {category}", category_products
            
        except Exception as e:
            error_msg = f"Failed to get products by category: {e}"
            self.logger.error(error_msg)
            return False, error_msg, []
