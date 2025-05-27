"""
Sync manager for synchronizing data between local database and Supabase.
For MVP, focuses on pulling data from Supabase to local database.
"""

from typing import List, Dict, Any, Optional
from datetime import datetime
from dateutil import parser

from local_db.local_db_manager import LocalDbManager
from .product_api_client import ProductApiClient
from .base_api_client import ApiException
from core.config_manager import ConfigManager
from app_logger.log_manager import LogManager


class SyncManager:
    """Manages synchronization between local database and Supabase."""
    
    def __init__(self, db_manager: LocalDbManager, product_api: ProductApiClient, config_manager: ConfigManager):
        """Initialize sync manager."""
        self.logger = LogManager().get_logger("SyncManager")
        self.db_manager = db_manager
        self.product_api = product_api
        self.config_manager = config_manager
        self.logger.info("Sync manager initialized")
    
    def sync_products(self, jwt_token: Optional[str] = None) -> Dict[str, Any]:
        """
        Synchronize products from Supabase to local database.
        Uses simple 'last write wins' conflict resolution based on updated_at.
        """
        if not self.product_api.is_available():
            self.logger.warning("Product API not available for sync")
            return {
                'success': False,
                'message': 'Product API not available',
                'synced_count': 0,
                'error_count': 0
            }
        
        try:
            self.logger.info("Starting product synchronization...")
            
            # Fetch products from Supabase
            api_products = self.product_api.get_all_products(jwt_token)
            
            synced_count = 0
            error_count = 0
            
            for api_product in api_products:
                try:
                    # Convert API product data to local format
                    local_product_data = self._convert_api_product_to_local(api_product)
                    
                    # Check if product exists locally
                    local_product = self.db_manager.get_product_by_id(local_product_data['id'])
                    
                    if local_product:
                        # Update existing product if API version is newer
                        if self._should_update_local_product(local_product, local_product_data):
                            updated_product = self.db_manager.update_product(
                                local_product.id,
                                **local_product_data
                            )
                            if updated_product:
                                synced_count += 1
                                self.logger.debug(f"Updated product: {local_product_data['name']}")
                        else:
                            self.logger.debug(f"Local product is up to date: {local_product_data['name']}")
                    else:
                        # Create new product
                        new_product = self.db_manager.create_product(**local_product_data)
                        if new_product:
                            synced_count += 1
                            self.logger.debug(f"Created product: {local_product_data['name']}")
                
                except Exception as e:
                    error_count += 1
                    self.logger.error(f"Failed to sync product {api_product.get('id', 'unknown')}: {e}")
            
            result = {
                'success': True,
                'message': f'Synchronized {synced_count} products with {error_count} errors',
                'synced_count': synced_count,
                'error_count': error_count
            }
            
            self.logger.info(f"Product sync completed: {result['message']}")
            return result
            
        except ApiException as e:
            error_msg = f"API error during sync: {e}"
            self.logger.error(error_msg)
            return {
                'success': False,
                'message': error_msg,
                'synced_count': 0,
                'error_count': 1
            }
        
        except Exception as e:
            error_msg = f"Unexpected error during sync: {e}"
            self.logger.error(error_msg)
            return {
                'success': False,
                'message': error_msg,
                'synced_count': 0,
                'error_count': 1
            }
    
    def _convert_api_product_to_local(self, api_product: Dict[str, Any]) -> Dict[str, Any]:
        """Convert API product format to local database format."""
        # Handle different price formats
        price = api_product.get('price', 0)
        if isinstance(price, (int, float)):
            # Assume API returns price in cents if it's an integer > 1000
            # Otherwise assume it's in dollars and convert to cents
            if isinstance(price, float) or (isinstance(price, int) and price < 1000):
                price = int(price * 100)  # Convert dollars to cents
        
        return {
            'id': api_product.get('id'),
            'name': api_product.get('name', ''),
            'description': api_product.get('description', ''),
            'price': price,
            'sku': api_product.get('sku', ''),
            'category': api_product.get('category', ''),
            'stock_quantity': api_product.get('stock_quantity', 0),
            'is_synced': True
        }
    
    def _should_update_local_product(self, local_product, api_product_data: Dict[str, Any]) -> bool:
        """
        Determine if local product should be updated with API data.
        For MVP, always update (simple overwrite strategy).
        """
        # For now, always update to ensure local data matches API
        # In a more sophisticated implementation, you might compare updated_at timestamps
        return True
    
    def mark_for_sync(self, table_name: str, record_id: int) -> bool:
        """
        Mark a local record as needing sync (for future implementation).
        """
        try:
            if table_name == 'products':
                product = self.db_manager.get_product_by_id(record_id)
                if product:
                    self.db_manager.update_product(record_id, is_synced=False)
                    self.logger.info(f"Marked product {record_id} for sync")
                    return True
            
            return False
            
        except Exception as e:
            self.logger.error(f"Failed to mark {table_name}:{record_id} for sync: {e}")
            return False
    
    def get_unsynced_records(self, table_name: str) -> List[Dict[str, Any]]:
        """
        Get records that need to be synced (for future implementation).
        """
        try:
            if table_name == 'products':
                with self.db_manager.get_session() as session:
                    from local_db.models import Product
                    unsynced_products = session.query(Product).filter(Product.is_synced == False).all()
                    return [product.to_dict() for product in unsynced_products]
            
            return []
            
        except Exception as e:
            self.logger.error(f"Failed to get unsynced {table_name}: {e}")
            return []
    
    def perform_full_sync(self, jwt_token: Optional[str] = None) -> Dict[str, Any]:
        """
        Perform a full synchronization of all data.
        For MVP, only syncs products from API to local.
        """
        self.logger.info("Starting full synchronization...")
        
        results = {
            'products': self.sync_products(jwt_token),
            'overall_success': True
        }
        
        # Check if any sync failed
        if not results['products']['success']:
            results['overall_success'] = False
        
        status = "completed successfully" if results['overall_success'] else "completed with errors"
        self.logger.info(f"Full synchronization {status}")
        
        return results
