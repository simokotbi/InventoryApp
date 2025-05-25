"""
Product API client for Supabase product operations.
"""

from typing import List, Dict, Any, Optional
from .base_api_client import BaseApiClient, ApiError


class ProductApiClient:
    """Handles product operations with Supabase."""
    
    def __init__(self, base_client: BaseApiClient):
        self.base_client = base_client
        self.table = "products"
    
    def get_all_products(self, active_only: bool = True) -> List[Dict[str, Any]]:
        """Get all products."""
        try:
            filters = {}
            if active_only:
                filters['is_active'] = True
            
            return self.base_client.select(self.table, filters=filters, order_by="name")
            
        except ApiError:
            raise
    
    def get_product_by_id(self, product_id: str) -> Optional[Dict[str, Any]]:
        """Get a product by ID."""
        try:
            products = self.base_client.select(self.table, filters={'id': product_id})
            return products[0] if products else None
            
        except ApiError:
            raise
    
    def get_product_by_sku(self, sku: str) -> Optional[Dict[str, Any]]:
        """Get a product by SKU."""
        try:
            products = self.base_client.select(self.table, filters={'sku': sku})
            return products[0] if products else None
            
        except ApiError:
            raise
    
    def search_products(self, search_term: str) -> List[Dict[str, Any]]:
        """Search products by name, SKU, or description."""
        try:
            # Supabase text search - this would need to be implemented based on your Supabase setup
            # For now, we'll do a simple name filter
            # In production, you might use Supabase's full-text search
            endpoint = f"rest/v1/{self.table}"
            params = {
                'select': '*',
                'or': f'name.ilike.%{search_term}%,sku.ilike.%{search_term}%,description.ilike.%{search_term}%'
            }
            
            response = self.base_client.get(endpoint, params=params)
            return response if isinstance(response, list) else []
            
        except ApiError:
            raise
    
    def create_product(self, product_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new product."""
        try:
            # Validate required fields
            required_fields = ['name', 'sku', 'unit_price', 'cost_price']
            for field in required_fields:
                if field not in product_data:
                    raise ApiError(f"Missing required field: {field}", 400)
            
            # Set defaults
            product_data.setdefault('is_active', True)
            product_data.setdefault('created_at', 'now()')
            product_data.setdefault('updated_at', 'now()')
            
            products = self.base_client.insert(self.table, product_data)
            return products[0] if products else {}
            
        except ApiError as e:
            if e.status_code == 409:
                raise ApiError("Product with this SKU already exists", 409)
            raise
    
    def update_product(self, product_id: str, product_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing product."""
        try:
            # Add updated timestamp
            product_data['updated_at'] = 'now()'
            
            products = self.base_client.update(self.table, product_data, {'id': product_id})
            return products[0] if products else {}
            
        except ApiError as e:
            if e.status_code == 404:
                raise ApiError("Product not found", 404)
            elif e.status_code == 409:
                raise ApiError("Product with this SKU already exists", 409)
            raise
    
    def delete_product(self, product_id: str) -> bool:
        """Delete a product (soft delete by setting is_active to False)."""
        try:
            products = self.base_client.update(
                self.table, 
                {'is_active': False, 'updated_at': 'now()'}, 
                {'id': product_id}
            )
            return len(products) > 0
            
        except ApiError:
            raise
    
    def get_products_by_category(self, category: str) -> List[Dict[str, Any]]:
        """Get products by category."""
        try:
            filters = {'category': category, 'is_active': True}
            return self.base_client.select(self.table, filters=filters, order_by="name")
            
        except ApiError:
            raise
    
    def get_low_stock_products(self) -> List[Dict[str, Any]]:
        """Get products with low stock (requires joining with inventory)."""
        try:
            # This would require a more complex query or view in Supabase
            # For now, return all products and let the business logic handle stock checking
            return self.get_all_products()
            
        except ApiError:
            raise
    
    def bulk_update_prices(self, price_updates: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Bulk update product prices."""
        try:
            updated_products = []
            for update in price_updates:
                if 'id' in update and ('unit_price' in update or 'cost_price' in update):
                    product_id = update.pop('id')
                    update['updated_at'] = 'now()'
                    
                    products = self.base_client.update(self.table, update, {'id': product_id})
                    if products:
                        updated_products.extend(products)
            
            return updated_products
            
        except ApiError:
            raise
    
    def get_product_categories(self) -> List[str]:
        """Get all unique product categories."""
        try:
            # This would require a distinct query in Supabase
            # For now, get all products and extract categories
            products = self.get_all_products()
            categories = set()
            for product in products:
                if product.get('category'):
                    categories.add(product['category'])
            
            return sorted(list(categories))
            
        except ApiError:
            raise
