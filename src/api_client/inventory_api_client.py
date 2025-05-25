"""
Inventory API client for Supabase inventory operations.
"""

from typing import List, Dict, Any, Optional
from .base_api_client import BaseApiClient, ApiError


class InventoryApiClient:
    """Handles inventory operations with Supabase."""
    
    def __init__(self, base_client: BaseApiClient):
        self.base_client = base_client
        self.inventory_table = "inventory"
        self.movements_table = "inventory_movements"
    
    def get_all_inventory(self) -> List[Dict[str, Any]]:
        """Get all inventory items."""
        try:
            return self.base_client.select(self.inventory_table, order_by="product_id")
            
        except ApiError:
            raise
    
    def get_inventory_by_id(self, inventory_id: str) -> Optional[Dict[str, Any]]:
        """Get inventory item by ID."""
        try:
            items = self.base_client.select(self.inventory_table, filters={'id': inventory_id})
            return items[0] if items else None
            
        except ApiError:
            raise
    
    def get_inventory_by_product(self, product_id: str) -> Optional[Dict[str, Any]]:
        """Get inventory item for a specific product."""
        try:
            items = self.base_client.select(self.inventory_table, filters={'product_id': product_id})
            return items[0] if items else None
            
        except ApiError:
            raise
    
    def get_low_stock_items(self) -> List[Dict[str, Any]]:
        """Get inventory items with stock below minimum."""
        try:
            # This requires a more complex query in Supabase
            # For now, get all items and filter in Python
            all_items = self.get_all_inventory()
            low_stock = []
            
            for item in all_items:
                current_stock = item.get('current_stock', 0)
                minimum_stock = item.get('minimum_stock', 0)
                if current_stock <= minimum_stock:
                    low_stock.append(item)
            
            return low_stock
            
        except ApiError:
            raise
    
    def create_inventory_item(self, inventory_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new inventory item."""
        try:
            # Validate required fields
            required_fields = ['product_id', 'current_stock', 'minimum_stock']
            for field in required_fields:
                if field not in inventory_data:
                    raise ApiError(f"Missing required field: {field}", 400)
            
            # Set defaults
            inventory_data.setdefault('created_at', 'now()')
            inventory_data.setdefault('updated_at', 'now()')
            
            items = self.base_client.insert(self.inventory_table, inventory_data)
            return items[0] if items else {}
            
        except ApiError as e:
            if e.status_code == 409:
                raise ApiError("Inventory item for this product already exists", 409)
            raise
    
    def update_inventory_item(self, inventory_id: str, inventory_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing inventory item."""
        try:
            # Add updated timestamp
            inventory_data['updated_at'] = 'now()'
            
            items = self.base_client.update(self.inventory_table, inventory_data, {'id': inventory_id})
            return items[0] if items else {}
            
        except ApiError as e:
            if e.status_code == 404:
                raise ApiError("Inventory item not found", 404)
            raise
    
    def update_stock_level(self, product_id: str, new_stock: float, 
                          movement_type: str, reason: str = "", 
                          reference_id: str = "") -> Dict[str, Any]:
        """Update stock level and create movement record."""
        try:
            # Get current inventory item
            current_item = self.get_inventory_by_product(product_id)
            
            if not current_item:
                raise ApiError("Inventory item not found for this product", 404)
            
            previous_stock = current_item.get('current_stock', 0)
            quantity_change = new_stock - previous_stock
            
            # Update inventory item
            update_data = {
                'current_stock': new_stock,
                'updated_at': 'now()'
            }
            
            if movement_type == 'in':
                update_data['last_restocked'] = 'now()'
            
            updated_item = self.update_inventory_item(current_item['id'], update_data)
            
            # Create movement record
            movement_data = {
                'inventory_id': current_item['id'],
                'movement_type': movement_type,
                'quantity': abs(quantity_change),
                'previous_stock': previous_stock,
                'new_stock': new_stock,
                'reason': reason,
                'reference_id': reference_id,
                'movement_date': 'now()',
                'created_at': 'now()'
            }
            
            self.create_inventory_movement(movement_data)
            
            return updated_item
            
        except ApiError:
            raise
    
    def adjust_stock(self, product_id: str, quantity_change: float, 
                    reason: str = "") -> Dict[str, Any]:
        """Adjust stock by a specific quantity."""
        try:
            current_item = self.get_inventory_by_product(product_id)
            
            if not current_item:
                raise ApiError("Inventory item not found for this product", 404)
            
            current_stock = current_item.get('current_stock', 0)
            new_stock = max(0, current_stock + quantity_change)  # Prevent negative stock
            
            movement_type = 'in' if quantity_change > 0 else 'out'
            
            return self.update_stock_level(product_id, new_stock, movement_type, reason)
            
        except ApiError:
            raise
    
    def get_inventory_movements(self, inventory_id: Optional[str] = None, 
                              limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get inventory movements."""
        try:
            filters = {}
            if inventory_id:
                filters['inventory_id'] = inventory_id
            
            return self.base_client.select(self.movements_table, 
                                         filters=filters,
                                         order_by="movement_date.desc",
                                         limit=limit)
            
        except ApiError:
            raise
    
    def create_inventory_movement(self, movement_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create an inventory movement record."""
        try:
            # Validate required fields
            required_fields = ['inventory_id', 'movement_type', 'quantity', 
                             'previous_stock', 'new_stock']
            for field in required_fields:
                if field not in movement_data:
                    raise ApiError(f"Missing required field: {field}", 400)
            
            # Set defaults
            movement_data.setdefault('movement_date', 'now()')
            movement_data.setdefault('created_at', 'now()')
            
            movements = self.base_client.insert(self.movements_table, movement_data)
            return movements[0] if movements else {}
            
        except ApiError:
            raise
    
    def get_stock_valuation(self) -> Dict[str, Any]:
        """Get total stock valuation."""
        try:
            # This would require joining with products table to get cost prices
            # For now, return basic inventory statistics
            all_items = self.get_all_inventory()
            
            total_items = len(all_items)
            total_stock = sum(item.get('current_stock', 0) for item in all_items)
            low_stock_items = len(self.get_low_stock_items())
            
            return {
                'total_products': total_items,
                'total_stock_units': total_stock,
                'low_stock_items': low_stock_items,
                'average_stock_per_product': total_stock / total_items if total_items > 0 else 0
            }
            
        except ApiError:
            raise
    
    def get_movement_history(self, product_id: str, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get movement history for a specific product."""
        try:
            # First get the inventory item for the product
            inventory_item = self.get_inventory_by_product(product_id)
            
            if not inventory_item:
                return []
            
            return self.get_inventory_movements(inventory_item['id'], limit)
            
        except ApiError:
            raise
    
    def bulk_update_stock_levels(self, updates: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Bulk update stock levels."""
        try:
            updated_items = []
            
            for update in updates:
                if 'product_id' in update and 'new_stock' in update:
                    try:
                        updated_item = self.update_stock_level(
                            update['product_id'],
                            update['new_stock'],
                            update.get('movement_type', 'adjustment'),
                            update.get('reason', 'Bulk update'),
                            update.get('reference_id', '')
                        )
                        updated_items.append(updated_item)
                    except ApiError:
                        # Continue with other updates if one fails
                        continue
            
            return updated_items
            
        except ApiError:
            raise
    
    def set_reorder_points(self, reorder_updates: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Set reorder points for multiple products."""
        try:
            updated_items = []
            
            for update in reorder_updates:
                if 'product_id' in update and 'reorder_point' in update:
                    inventory_item = self.get_inventory_by_product(update['product_id'])
                    
                    if inventory_item:
                        updated_item = self.update_inventory_item(
                            inventory_item['id'],
                            {'reorder_point': update['reorder_point']}
                        )
                        updated_items.append(updated_item)
            
            return updated_items
            
        except ApiError:
            raise
