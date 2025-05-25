"""
Customer API client for Supabase customer operations.
"""

from typing import List, Dict, Any, Optional
from .base_api_client import BaseApiClient, ApiError


class CustomerApiClient:
    """Handles customer operations with Supabase."""
    
    def __init__(self, base_client: BaseApiClient):
        self.base_client = base_client
        self.table = "customers"
    
    def get_all_customers(self, active_only: bool = True) -> List[Dict[str, Any]]:
        """Get all customers."""
        try:
            filters = {}
            if active_only:
                filters['is_active'] = True
            
            return self.base_client.select(self.table, filters=filters, order_by="last_name,first_name")
            
        except ApiError:
            raise
    
    def get_customer_by_id(self, customer_id: str) -> Optional[Dict[str, Any]]:
        """Get a customer by ID."""
        try:
            customers = self.base_client.select(self.table, filters={'id': customer_id})
            return customers[0] if customers else None
            
        except ApiError:
            raise
    
    def get_customer_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get a customer by email."""
        try:
            customers = self.base_client.select(self.table, filters={'email': email})
            return customers[0] if customers else None
            
        except ApiError:
            raise
    
    def search_customers(self, search_term: str) -> List[Dict[str, Any]]:
        """Search customers by name, email, or phone."""
        try:
            endpoint = f"rest/v1/{self.table}"
            params = {
                'select': '*',
                'or': f'first_name.ilike.%{search_term}%,last_name.ilike.%{search_term}%,email.ilike.%{search_term}%,phone.ilike.%{search_term}%'
            }
            
            response = self.base_client.get(endpoint, params=params)
            return response if isinstance(response, list) else []
            
        except ApiError:
            raise
    
    def create_customer(self, customer_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new customer."""
        try:
            # Validate required fields
            required_fields = ['first_name', 'last_name']
            for field in required_fields:
                if field not in customer_data:
                    raise ApiError(f"Missing required field: {field}", 400)
            
            # Set defaults
            customer_data.setdefault('is_active', True)
            customer_data.setdefault('created_at', 'now()')
            customer_data.setdefault('updated_at', 'now()')
            
            customers = self.base_client.insert(self.table, customer_data)
            return customers[0] if customers else {}
            
        except ApiError as e:
            if e.status_code == 409:
                raise ApiError("Customer with this email already exists", 409)
            raise
    
    def update_customer(self, customer_id: str, customer_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing customer."""
        try:
            # Add updated timestamp
            customer_data['updated_at'] = 'now()'
            
            customers = self.base_client.update(self.table, customer_data, {'id': customer_id})
            return customers[0] if customers else {}
            
        except ApiError as e:
            if e.status_code == 404:
                raise ApiError("Customer not found", 404)
            elif e.status_code == 409:
                raise ApiError("Customer with this email already exists", 409)
            raise
    
    def delete_customer(self, customer_id: str) -> bool:
        """Delete a customer (soft delete by setting is_active to False)."""
        try:
            customers = self.base_client.update(
                self.table, 
                {'is_active': False, 'updated_at': 'now()'}, 
                {'id': customer_id}
            )
            return len(customers) > 0
            
        except ApiError:
            raise
    
    def get_customers_by_city(self, city: str) -> List[Dict[str, Any]]:
        """Get customers by city."""
        try:
            filters = {'city': city, 'is_active': True}
            return self.base_client.select(self.table, filters=filters, order_by="last_name,first_name")
            
        except ApiError:
            raise
    
    def get_customers_by_country(self, country: str) -> List[Dict[str, Any]]:
        """Get customers by country."""
        try:
            filters = {'country': country, 'is_active': True}
            return self.base_client.select(self.table, filters=filters, order_by="last_name,first_name")
            
        except ApiError:
            raise
    
    def get_customer_sales_history(self, customer_id: str) -> List[Dict[str, Any]]:
        """Get sales history for a customer."""
        try:
            # This would require joining with sales table
            # For now, we'll need to handle this in the business logic layer
            # In Supabase, you might use a view or RPC function
            return []
            
        except ApiError:
            raise
    
    def get_top_customers(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Get top customers by sales volume."""
        try:
            # This would require complex aggregation with sales data
            # For now, return recent customers
            return self.base_client.select(self.table, 
                                         filters={'is_active': True}, 
                                         order_by="created_at.desc", 
                                         limit=limit)
            
        except ApiError:
            raise
    
    def bulk_import_customers(self, customers_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Bulk import customers."""
        try:
            # Validate and prepare data
            prepared_customers = []
            for customer in customers_data:
                # Validate required fields
                if 'first_name' not in customer or 'last_name' not in customer:
                    continue
                
                # Set defaults
                customer.setdefault('is_active', True)
                customer.setdefault('created_at', 'now()')
                customer.setdefault('updated_at', 'now()')
                
                prepared_customers.append(customer)
            
            if not prepared_customers:
                raise ApiError("No valid customers to import", 400)
            
            return self.base_client.insert(self.table, prepared_customers)
            
        except ApiError:
            raise
    
    def get_customer_statistics(self) -> Dict[str, Any]:
        """Get customer statistics."""
        try:
            # Get basic counts - in production, this would be optimized with aggregate queries
            all_customers = self.get_all_customers(active_only=False)
            active_customers = [c for c in all_customers if c.get('is_active', True)]
            
            # Group by country
            countries = {}
            for customer in active_customers:
                country = customer.get('country', 'Unknown')
                countries[country] = countries.get(country, 0) + 1
            
            return {
                'total_customers': len(all_customers),
                'active_customers': len(active_customers),
                'inactive_customers': len(all_customers) - len(active_customers),
                'customers_by_country': countries
            }
            
        except ApiError:
            raise
