"""
Sales API client for Supabase sales operations.
"""

from typing import List, Dict, Any, Optional
from datetime import datetime, date
from .base_api_client import BaseApiClient, ApiError


class SalesApiClient:
    """Handles sales operations with Supabase."""
    
    def __init__(self, base_client: BaseApiClient):
        self.base_client = base_client
        self.sales_table = "sales"
        self.sale_items_table = "sale_items"
    
    def get_all_sales(self, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get all sales."""
        try:
            return self.base_client.select(self.sales_table, 
                                         order_by="sale_date.desc", 
                                         limit=limit)
            
        except ApiError:
            raise
    
    def get_sale_by_id(self, sale_id: str) -> Optional[Dict[str, Any]]:
        """Get a sale by ID."""
        try:
            sales = self.base_client.select(self.sales_table, filters={'id': sale_id})
            return sales[0] if sales else None
            
        except ApiError:
            raise
    
    def get_sale_by_number(self, sale_number: str) -> Optional[Dict[str, Any]]:
        """Get a sale by sale number."""
        try:
            sales = self.base_client.select(self.sales_table, filters={'sale_number': sale_number})
            return sales[0] if sales else None
            
        except ApiError:
            raise
    
    def get_sales_by_customer(self, customer_id: str) -> List[Dict[str, Any]]:
        """Get sales for a specific customer."""
        try:
            return self.base_client.select(self.sales_table, 
                                         filters={'customer_id': customer_id},
                                         order_by="sale_date.desc")
            
        except ApiError:
            raise
    
    def get_sales_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        """Get sales for a specific user."""
        try:
            return self.base_client.select(self.sales_table, 
                                         filters={'user_id': user_id},
                                         order_by="sale_date.desc")
            
        except ApiError:
            raise
    
    def get_sales_by_date_range(self, start_date: date, end_date: date) -> List[Dict[str, Any]]:
        """Get sales within a date range."""
        try:
            endpoint = f"rest/v1/{self.sales_table}"
            params = {
                'select': '*',
                'sale_date': f'gte.{start_date.isoformat()}',
                'sale_date': f'lte.{end_date.isoformat()}',
                'order': 'sale_date.desc'
            }
            
            response = self.base_client.get(endpoint, params=params)
            return response if isinstance(response, list) else []
            
        except ApiError:
            raise
    
    def create_sale(self, sale_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new sale."""
        try:
            # Validate required fields
            required_fields = ['sale_number', 'user_id', 'total_amount']
            for field in required_fields:
                if field not in sale_data:
                    raise ApiError(f"Missing required field: {field}", 400)
            
            # Set defaults
            sale_data.setdefault('subtotal', 0.0)
            sale_data.setdefault('tax_amount', 0.0)
            sale_data.setdefault('discount_amount', 0.0)
            sale_data.setdefault('payment_status', 'pending')
            sale_data.setdefault('sale_date', 'now()')
            sale_data.setdefault('created_at', 'now()')
            sale_data.setdefault('updated_at', 'now()')
            
            sales = self.base_client.insert(self.sales_table, sale_data)
            return sales[0] if sales else {}
            
        except ApiError as e:
            if e.status_code == 409:
                raise ApiError("Sale with this number already exists", 409)
            raise
    
    def update_sale(self, sale_id: str, sale_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing sale."""
        try:
            # Add updated timestamp
            sale_data['updated_at'] = 'now()'
            
            sales = self.base_client.update(self.sales_table, sale_data, {'id': sale_id})
            return sales[0] if sales else {}
            
        except ApiError as e:
            if e.status_code == 404:
                raise ApiError("Sale not found", 404)
            raise
    
    def delete_sale(self, sale_id: str) -> bool:
        """Delete a sale and its items."""
        try:
            # First delete sale items
            self.base_client.delete_records(self.sale_items_table, {'sale_id': sale_id})
            
            # Then delete the sale
            sales = self.base_client.delete_records(self.sales_table, {'id': sale_id})
            return len(sales) > 0
            
        except ApiError:
            raise
    
    def get_sale_items(self, sale_id: str) -> List[Dict[str, Any]]:
        """Get items for a specific sale."""
        try:
            return self.base_client.select(self.sale_items_table, 
                                         filters={'sale_id': sale_id})
            
        except ApiError:
            raise
    
    def add_sale_item(self, sale_item_data: Dict[str, Any]) -> Dict[str, Any]:
        """Add an item to a sale."""
        try:
            # Validate required fields
            required_fields = ['sale_id', 'product_id', 'quantity', 'unit_price', 'total_amount']
            for field in required_fields:
                if field not in sale_item_data:
                    raise ApiError(f"Missing required field: {field}", 400)
            
            # Set defaults
            sale_item_data.setdefault('discount_amount', 0.0)
            sale_item_data.setdefault('created_at', 'now()')
            
            items = self.base_client.insert(self.sale_items_table, sale_item_data)
            return items[0] if items else {}
            
        except ApiError:
            raise
    
    def update_sale_item(self, item_id: str, item_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update a sale item."""
        try:
            items = self.base_client.update(self.sale_items_table, item_data, {'id': item_id})
            return items[0] if items else {}
            
        except ApiError:
            raise
    
    def remove_sale_item(self, item_id: str) -> bool:
        """Remove an item from a sale."""
        try:
            items = self.base_client.delete_records(self.sale_items_table, {'id': item_id})
            return len(items) > 0
            
        except ApiError:
            raise
    
    def update_payment_status(self, sale_id: str, payment_status: str, 
                             payment_method: Optional[str] = None) -> Dict[str, Any]:
        """Update payment status for a sale."""
        try:
            update_data = {
                'payment_status': payment_status,
                'updated_at': 'now()'
            }
            
            if payment_method:
                update_data['payment_method'] = payment_method
            
            sales = self.base_client.update(self.sales_table, update_data, {'id': sale_id})
            return sales[0] if sales else {}
            
        except ApiError:
            raise
    
    def get_sales_summary(self, start_date: Optional[date] = None, 
                         end_date: Optional[date] = None) -> Dict[str, Any]:
        """Get sales summary statistics."""
        try:
            # Get sales for the period
            if start_date and end_date:
                sales = self.get_sales_by_date_range(start_date, end_date)
            else:
                sales = self.get_all_sales()
            
            # Calculate summary statistics
            total_sales = len(sales)
            total_revenue = sum(sale.get('total_amount', 0) for sale in sales)
            paid_sales = [sale for sale in sales if sale.get('payment_status') == 'paid']
            paid_revenue = sum(sale.get('total_amount', 0) for sale in paid_sales)
            
            # Group by payment status
            status_counts = {}
            for sale in sales:
                status = sale.get('payment_status', 'unknown')
                status_counts[status] = status_counts.get(status, 0) + 1
            
            return {
                'total_sales': total_sales,
                'total_revenue': total_revenue,
                'paid_sales': len(paid_sales),
                'paid_revenue': paid_revenue,
                'pending_revenue': total_revenue - paid_revenue,
                'average_sale_amount': total_revenue / total_sales if total_sales > 0 else 0,
                'sales_by_status': status_counts
            }
            
        except ApiError:
            raise
    
    def generate_sale_number(self) -> str:
        """Generate a unique sale number."""
        try:
            # Get the latest sale to generate next number
            sales = self.base_client.select(self.sales_table, 
                                          order_by="created_at.desc", 
                                          limit=1)
            
            if sales:
                try:
                    # Extract number from sale_number (format: SALE-XXXX)
                    latest_number = sales[0].get('sale_number', 'SALE-0000')
                    number = int(latest_number.split('-')[1]) + 1
                except (IndexError, ValueError):
                    number = 1
            else:
                number = 1
            
            return f"SALE-{number:04d}"
            
        except ApiError:
            # Fallback to timestamp-based number
            timestamp = int(datetime.now().timestamp())
            return f"SALE-{timestamp}"
