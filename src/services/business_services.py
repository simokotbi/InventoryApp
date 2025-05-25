"""
Business Logic Services

Provides high-level business logic abstraction layer between UI and data layers.
Handles complex business operations, validations, and cross-cutting concerns.
"""
from typing import List, Dict, Any, Optional, Union, Tuple
from decimal import Decimal
from datetime import datetime, timezone
from enum import Enum

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from loguru import logger

from local_db.local_db_manager import LocalDbManager
from local_db.models import (
    User, Product, Customer, Sale, SaleItem, 
    InventoryItem, InventoryMovement, AppSettings
)
from api_client.sync_manager import SyncManager
from core.config_manager import ConfigManager


class ServiceResult:
    """Standard result wrapper for service operations"""
    
    def __init__(self, success: bool, data: Any = None, message: str = "", errors: List[str] = None):
        self.success = success
        self.data = data
        self.message = message
        self.errors = errors or []
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "success": self.success,
            "data": self.data,
            "message": self.message,
            "errors": self.errors
        }


class UserService:
    """Business logic for user management"""
    
    def __init__(self, local_db: LocalDbManager, sync_manager: SyncManager):
        self.local_db = local_db
        self.sync_manager = sync_manager
    
    def create_user(
        self, 
        username: str, 
        email: str, 
        password: str, 
        full_name: str,
        role: str = "employee"
    ) -> ServiceResult:
        """Create a new user with validation"""
        try:
            # Validate input
            if not username or len(username) < 3:
                return ServiceResult(False, errors=["Username must be at least 3 characters"])
            
            if not email or "@" not in email:
                return ServiceResult(False, errors=["Invalid email address"])
            
            if not password or len(password) < 6:
                return ServiceResult(False, errors=["Password must be at least 6 characters"])
            
            # Check if user already exists
            with self.local_db.get_session() as session:
                existing_user = session.query(User).filter(
                    or_(User.username == username, User.email == email)
                ).first()
                
                if existing_user:
                    return ServiceResult(False, errors=["Username or email already exists"])
                
                # Create user
                user_data = {
                    "username": username,
                    "email": email,
                    "password": password,  # Will be hashed in the model
                    "full_name": full_name,
                    "role": role,
                    "is_active": True
                }
                
                user = self.local_db.create_user(user_data)
                
                if user:
                    logger.info(f"User created: {username}")
                    return ServiceResult(True, data=user.to_dict(), message="User created successfully")
                else:
                    return ServiceResult(False, errors=["Failed to create user"])
                    
        except Exception as e:
            logger.error(f"Error creating user: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def authenticate_user(self, username: str, password: str) -> ServiceResult:
        """Authenticate user credentials"""
        try:
            with self.local_db.get_session() as session:
                user = session.query(User).filter(
                    and_(
                        or_(User.username == username, User.email == username),
                        User.is_active == True
                    )
                ).first()
                
                if user and user.check_password(password):
                    # Update last login
                    user.last_login = datetime.now(timezone.utc)
                    session.commit()
                    
                    logger.info(f"User authenticated: {username}")
                    return ServiceResult(True, data=user.to_dict(), message="Authentication successful")
                else:
                    logger.warning(f"Authentication failed for: {username}")
                    return ServiceResult(False, errors=["Invalid credentials"])
                    
        except Exception as e:
            logger.error(f"Error authenticating user: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def get_user_permissions(self, user_id: int) -> ServiceResult:
        """Get user permissions based on role"""
        try:
            user = self.local_db.get_user_by_id(user_id)
            if not user:
                return ServiceResult(False, errors=["User not found"])
            
            # Define role-based permissions
            permissions = {
                "admin": {
                    "users": ["create", "read", "update", "delete"],
                    "products": ["create", "read", "update", "delete"],
                    "customers": ["create", "read", "update", "delete"],
                    "sales": ["create", "read", "update", "delete"],
                    "inventory": ["create", "read", "update", "delete"],
                    "reports": ["read"],
                    "settings": ["read", "update"]
                },
                "manager": {
                    "users": ["read"],
                    "products": ["create", "read", "update"],
                    "customers": ["create", "read", "update"],
                    "sales": ["create", "read", "update"],
                    "inventory": ["read", "update"],
                    "reports": ["read"],
                    "settings": ["read"]
                },
                "employee": {
                    "products": ["read"],
                    "customers": ["create", "read", "update"],
                    "sales": ["create", "read"],
                    "inventory": ["read"],
                    "reports": [],
                    "settings": []
                }
            }
            
            user_permissions = permissions.get(user.role, permissions["employee"])
            return ServiceResult(True, data=user_permissions)
            
        except Exception as e:
            logger.error(f"Error getting user permissions: {e}")
            return ServiceResult(False, errors=[str(e)])


class ProductService:
    """Business logic for product management"""
    
    def __init__(self, local_db: LocalDbManager, sync_manager: SyncManager):
        self.local_db = local_db
        self.sync_manager = sync_manager
    
    def create_product(self, product_data: Dict[str, Any]) -> ServiceResult:
        """Create a new product with validation"""
        try:
            # Validate required fields
            required_fields = ["name", "price", "category"]
            for field in required_fields:
                if not product_data.get(field):
                    return ServiceResult(False, errors=[f"{field} is required"])
            
            # Validate price
            try:
                price = Decimal(str(product_data["price"]))
                if price < 0:
                    return ServiceResult(False, errors=["Price cannot be negative"])
                product_data["price"] = price
            except:
                return ServiceResult(False, errors=["Invalid price format"])
            
            # Check if SKU already exists (if provided)
            if product_data.get("sku"):
                with self.local_db.get_session() as session:
                    existing = session.query(Product).filter(Product.sku == product_data["sku"]).first()
                    if existing:
                        return ServiceResult(False, errors=["SKU already exists"])
            
            product = self.local_db.create_product(product_data)
            
            if product:
                logger.info(f"Product created: {product.name}")
                return ServiceResult(True, data=product.to_dict(), message="Product created successfully")
            else:
                return ServiceResult(False, errors=["Failed to create product"])
                
        except Exception as e:
            logger.error(f"Error creating product: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def search_products(
        self, 
        query: str = "", 
        category: str = "", 
        active_only: bool = True,
        limit: int = 50
    ) -> ServiceResult:
        """Search products with filters"""
        try:
            with self.local_db.get_session() as session:
                q = session.query(Product)
                
                if active_only:
                    q = q.filter(Product.is_active == True)
                
                if query:
                    q = q.filter(
                        or_(
                            Product.name.ilike(f"%{query}%"),
                            Product.sku.ilike(f"%{query}%"),
                            Product.description.ilike(f"%{query}%")
                        )
                    )
                
                if category:
                    q = q.filter(Product.category == category)
                
                products = q.limit(limit).all()
                
                result = [product.to_dict() for product in products]
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error searching products: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def update_product_price(self, product_id: int, new_price: Decimal) -> ServiceResult:
        """Update product price with validation"""
        try:
            if new_price < 0:
                return ServiceResult(False, errors=["Price cannot be negative"])
            
            product = self.local_db.get_product_by_id(product_id)
            if not product:
                return ServiceResult(False, errors=["Product not found"])
            
            old_price = product.price
            
            update_data = {"price": new_price}
            updated_product = self.local_db.update_product(product_id, update_data)
            
            if updated_product:
                logger.info(f"Product price updated: {product.name} from {old_price} to {new_price}")
                return ServiceResult(True, data=updated_product.to_dict(), message="Price updated successfully")
            else:
                return ServiceResult(False, errors=["Failed to update price"])
                
        except Exception as e:
            logger.error(f"Error updating product price: {e}")
            return ServiceResult(False, errors=[str(e)])


class CustomerService:
    """Business logic for customer management"""
    
    def __init__(self, local_db: LocalDbManager, sync_manager: SyncManager):
        self.local_db = local_db
        self.sync_manager = sync_manager
    
    def create_customer(self, customer_data: Dict[str, Any]) -> ServiceResult:
        """Create a new customer with validation"""
        try:
            # Validate required fields
            if not customer_data.get("name"):
                return ServiceResult(False, errors=["Customer name is required"])
            
            # Validate email format if provided
            email = customer_data.get("email")
            if email and "@" not in email:
                return ServiceResult(False, errors=["Invalid email format"])
            
            # Check for duplicate email
            if email:
                with self.local_db.get_session() as session:
                    existing = session.query(Customer).filter(Customer.email == email).first()
                    if existing:
                        return ServiceResult(False, errors=["Email already exists"])
            
            customer = self.local_db.create_customer(customer_data)
            
            if customer:
                logger.info(f"Customer created: {customer.name}")
                return ServiceResult(True, data=customer.to_dict(), message="Customer created successfully")
            else:
                return ServiceResult(False, errors=["Failed to create customer"])
                
        except Exception as e:
            logger.error(f"Error creating customer: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def search_customers(self, query: str = "", limit: int = 50) -> ServiceResult:
        """Search customers by name, email, or phone"""
        try:
            with self.local_db.get_session() as session:
                q = session.query(Customer)
                
                if query:
                    q = q.filter(
                        or_(
                            Customer.name.ilike(f"%{query}%"),
                            Customer.email.ilike(f"%{query}%"),
                            Customer.phone.ilike(f"%{query}%")
                        )
                    )
                
                customers = q.limit(limit).all()
                
                result = [customer.to_dict() for customer in customers]
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error searching customers: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def get_customer_purchase_history(self, customer_id: int) -> ServiceResult:
        """Get customer's purchase history"""
        try:
            with self.local_db.get_session() as session:
                customer = session.query(Customer).filter(Customer.id == customer_id).first()
                if not customer:
                    return ServiceResult(False, errors=["Customer not found"])
                
                sales = session.query(Sale).filter(
                    Sale.customer_id == customer_id
                ).order_by(desc(Sale.created_at)).all()
                
                result = {
                    "customer": customer.to_dict(),
                    "sales": [sale.to_dict() for sale in sales],
                    "total_purchases": len(sales),
                    "total_amount": sum(sale.total_amount for sale in sales)
                }
                
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error getting customer purchase history: {e}")
            return ServiceResult(False, errors=[str(e)])


class SalesService:
    """Business logic for sales management"""
    
    def __init__(self, local_db: LocalDbManager, sync_manager: SyncManager):
        self.local_db = local_db
        self.sync_manager = sync_manager
    
    def create_sale(
        self, 
        customer_id: Optional[int], 
        items: List[Dict[str, Any]], 
        payment_method: str = "cash",
        user_id: Optional[int] = None
    ) -> ServiceResult:
        """Create a new sale with validation"""
        try:
            # Validate items
            if not items:
                return ServiceResult(False, errors=["At least one item is required"])
            
            validated_items = []
            total_amount = Decimal('0')
            
            with self.local_db.get_session() as session:
                # Validate customer if provided
                if customer_id:
                    customer = session.query(Customer).filter(Customer.id == customer_id).first()
                    if not customer:
                        return ServiceResult(False, errors=["Customer not found"])
                
                # Validate and process each item
                for item in items:
                    product_id = item.get("product_id")
                    quantity = item.get("quantity", 1)
                    
                    if not product_id:
                        return ServiceResult(False, errors=["Product ID is required for all items"])
                    
                    try:
                        quantity = Decimal(str(quantity))
                        if quantity <= 0:
                            return ServiceResult(False, errors=["Quantity must be positive"])
                    except:
                        return ServiceResult(False, errors=["Invalid quantity format"])
                    
                    # Check product exists and is active
                    product = session.query(Product).filter(
                        and_(Product.id == product_id, Product.is_active == True)
                    ).first()
                    
                    if not product:
                        return ServiceResult(False, errors=[f"Product not found or inactive: {product_id}"])
                    
                    # Check inventory if tracking is enabled
                    if product.track_inventory:
                        inventory = session.query(InventoryItem).filter(
                            InventoryItem.product_id == product_id
                        ).first()
                        
                        if not inventory or inventory.quantity_available < quantity:
                            return ServiceResult(False, errors=[f"Insufficient inventory for {product.name}"])
                    
                    # Calculate item total
                    unit_price = item.get("unit_price", product.price)
                    item_total = quantity * Decimal(str(unit_price))
                    total_amount += item_total
                    
                    validated_items.append({
                        "product_id": product_id,
                        "quantity": quantity,
                        "unit_price": unit_price,
                        "total_price": item_total
                    })
                
                # Create sale
                sale_data = {
                    "customer_id": customer_id,
                    "total_amount": total_amount,
                    "payment_method": payment_method,
                    "status": "completed",
                    "created_by": user_id
                }
                
                sale = self.local_db.create_sale(sale_data)
                
                if not sale:
                    return ServiceResult(False, errors=["Failed to create sale"])
                
                # Create sale items
                for item_data in validated_items:
                    item_data["sale_id"] = sale.id
                    sale_item = self.local_db.create_sale_item(item_data)
                    
                    if not sale_item:
                        # Rollback sale if item creation fails
                        session.delete(sale)
                        session.commit()
                        return ServiceResult(False, errors=["Failed to create sale items"])
                    
                    # Update inventory
                    if item_data["product_id"]:
                        product = session.query(Product).filter(Product.id == item_data["product_id"]).first()
                        if product and product.track_inventory:
                            self._update_inventory_for_sale(
                                session, 
                                item_data["product_id"], 
                                item_data["quantity"]
                            )
                
                session.commit()
                
                logger.info(f"Sale created: {sale.id} for amount {total_amount}")
                return ServiceResult(True, data=sale.to_dict(), message="Sale created successfully")
                
        except Exception as e:
            logger.error(f"Error creating sale: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def _update_inventory_for_sale(self, session: Session, product_id: int, quantity: Decimal):
        """Update inventory when a sale is made"""
        try:
            inventory = session.query(InventoryItem).filter(
                InventoryItem.product_id == product_id
            ).first()
            
            if inventory:
                inventory.quantity_available -= quantity
                inventory.updated_at = datetime.now(timezone.utc)
                
                # Create inventory movement record
                movement_data = {
                    "product_id": product_id,
                    "movement_type": "outbound",
                    "quantity": quantity,
                    "reason": "sale",
                    "notes": f"Sale transaction"
                }
                
                movement = InventoryMovement(**movement_data)
                session.add(movement)
                
        except Exception as e:
            logger.error(f"Error updating inventory for sale: {e}")
    
    def get_sales_by_date_range(
        self, 
        start_date: datetime, 
        end_date: datetime,
        user_id: Optional[int] = None
    ) -> ServiceResult:
        """Get sales within a date range"""
        try:
            with self.local_db.get_session() as session:
                q = session.query(Sale).filter(
                    and_(
                        Sale.created_at >= start_date,
                        Sale.created_at <= end_date
                    )
                )
                
                if user_id:
                    q = q.filter(Sale.created_by == user_id)
                
                sales = q.order_by(desc(Sale.created_at)).all()
                
                # Calculate summary statistics
                total_sales = len(sales)
                total_amount = sum(sale.total_amount for sale in sales)
                avg_sale_amount = total_amount / total_sales if total_sales > 0 else 0
                
                result = {
                    "sales": [sale.to_dict() for sale in sales],
                    "summary": {
                        "total_sales": total_sales,
                        "total_amount": float(total_amount),
                        "average_sale_amount": float(avg_sale_amount),
                        "date_range": {
                            "start": start_date.isoformat(),
                            "end": end_date.isoformat()
                        }
                    }
                }
                
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error getting sales by date range: {e}")
            return ServiceResult(False, errors=[str(e)])


class InventoryService:
    """Business logic for inventory management"""
    
    def __init__(self, local_db: LocalDbManager, sync_manager: SyncManager):
        self.local_db = local_db
        self.sync_manager = sync_manager
    
    def add_inventory(
        self, 
        product_id: int, 
        quantity: Decimal, 
        reason: str = "restock",
        notes: str = ""
    ) -> ServiceResult:
        """Add inventory for a product"""
        try:
            with self.local_db.get_session() as session:
                # Check if product exists
                product = session.query(Product).filter(Product.id == product_id).first()
                if not product:
                    return ServiceResult(False, errors=["Product not found"])
                
                if not product.track_inventory:
                    return ServiceResult(False, errors=["Product does not track inventory"])
                
                # Get or create inventory item
                inventory = session.query(InventoryItem).filter(
                    InventoryItem.product_id == product_id
                ).first()
                
                if not inventory:
                    inventory_data = {
                        "product_id": product_id,
                        "quantity_available": quantity,
                        "minimum_stock_level": 0
                    }
                    inventory = self.local_db.create_inventory_item(inventory_data)
                else:
                    inventory.quantity_available += quantity
                    inventory.updated_at = datetime.now(timezone.utc)
                    inventory.is_synced = False
                
                # Create movement record
                movement_data = {
                    "product_id": product_id,
                    "movement_type": "inbound",
                    "quantity": quantity,
                    "reason": reason,
                    "notes": notes
                }
                
                movement = self.local_db.create_inventory_movement(movement_data)
                
                if inventory and movement:
                    session.commit()
                    logger.info(f"Inventory added: {quantity} units for product {product_id}")
                    return ServiceResult(True, data=inventory.to_dict(), message="Inventory added successfully")
                else:
                    return ServiceResult(False, errors=["Failed to add inventory"])
                    
        except Exception as e:
            logger.error(f"Error adding inventory: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def get_low_stock_items(self) -> ServiceResult:
        """Get items with low stock levels"""
        try:
            with self.local_db.get_session() as session:
                low_stock_items = session.query(InventoryItem).filter(
                    InventoryItem.quantity_available <= InventoryItem.minimum_stock_level
                ).all()
                
                result = []
                for item in low_stock_items:
                    product = session.query(Product).filter(Product.id == item.product_id).first()
                    if product:
                        result.append({
                            "inventory": item.to_dict(),
                            "product": product.to_dict(),
                            "shortage": float(item.minimum_stock_level - item.quantity_available)
                        })
                
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error getting low stock items: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def get_inventory_movements(
        self, 
        product_id: Optional[int] = None,
        movement_type: Optional[str] = None,
        limit: int = 100
    ) -> ServiceResult:
        """Get inventory movement history"""
        try:
            with self.local_db.get_session() as session:
                q = session.query(InventoryMovement)
                
                if product_id:
                    q = q.filter(InventoryMovement.product_id == product_id)
                
                if movement_type:
                    q = q.filter(InventoryMovement.movement_type == movement_type)
                
                movements = q.order_by(desc(InventoryMovement.created_at)).limit(limit).all()
                
                result = [movement.to_dict() for movement in movements]
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error getting inventory movements: {e}")
            return ServiceResult(False, errors=[str(e)])


class ReportService:
    """Business logic for reports and analytics"""
    
    def __init__(self, local_db: LocalDbManager):
        self.local_db = local_db
    
    def get_sales_summary(
        self, 
        start_date: datetime, 
        end_date: datetime
    ) -> ServiceResult:
        """Generate sales summary report"""
        try:
            with self.local_db.get_session() as session:
                # Basic sales metrics
                sales = session.query(Sale).filter(
                    and_(
                        Sale.created_at >= start_date,
                        Sale.created_at <= end_date
                    )
                ).all()
                
                total_sales = len(sales)
                total_revenue = sum(sale.total_amount for sale in sales)
                
                # Sales by day
                sales_by_day = {}
                for sale in sales:
                    day = sale.created_at.date().isoformat()
                    if day not in sales_by_day:
                        sales_by_day[day] = {"count": 0, "amount": 0}
                    sales_by_day[day]["count"] += 1
                    sales_by_day[day]["amount"] += float(sale.total_amount)
                
                # Top products
                top_products_query = session.query(
                    Product.name,
                    func.sum(SaleItem.quantity).label('total_quantity'),
                    func.sum(SaleItem.total_price).label('total_revenue')
                ).join(SaleItem).join(Sale).filter(
                    and_(
                        Sale.created_at >= start_date,
                        Sale.created_at <= end_date
                    )
                ).group_by(Product.id, Product.name).order_by(
                    desc('total_revenue')
                ).limit(10).all()
                
                top_products = [
                    {
                        "name": name,
                        "quantity_sold": int(quantity),
                        "revenue": float(revenue)
                    }
                    for name, quantity, revenue in top_products_query
                ]
                
                result = {
                    "period": {
                        "start_date": start_date.isoformat(),
                        "end_date": end_date.isoformat()
                    },
                    "summary": {
                        "total_sales": total_sales,
                        "total_revenue": float(total_revenue),
                        "average_sale_amount": float(total_revenue / total_sales) if total_sales > 0 else 0
                    },
                    "sales_by_day": sales_by_day,
                    "top_products": top_products
                }
                
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error generating sales summary: {e}")
            return ServiceResult(False, errors=[str(e)])
    
    def get_inventory_report(self) -> ServiceResult:
        """Generate inventory status report"""
        try:
            with self.local_db.get_session() as session:
                # Get all inventory items with product details
                inventory_query = session.query(InventoryItem, Product).join(
                    Product, InventoryItem.product_id == Product.id
                ).all()
                
                inventory_items = []
                total_value = Decimal('0')
                low_stock_count = 0
                
                for inventory, product in inventory_query:
                    item_value = inventory.quantity_available * product.price
                    total_value += item_value
                    
                    is_low_stock = inventory.quantity_available <= inventory.minimum_stock_level
                    if is_low_stock:
                        low_stock_count += 1
                    
                    inventory_items.append({
                        "product_name": product.name,
                        "sku": product.sku,
                        "category": product.category,
                        "quantity_available": float(inventory.quantity_available),
                        "minimum_stock_level": float(inventory.minimum_stock_level),
                        "unit_price": float(product.price),
                        "total_value": float(item_value),
                        "is_low_stock": is_low_stock
                    })
                
                result = {
                    "summary": {
                        "total_products": len(inventory_items),
                        "total_inventory_value": float(total_value),
                        "low_stock_items": low_stock_count
                    },
                    "inventory_items": inventory_items
                }
                
                return ServiceResult(True, data=result)
                
        except Exception as e:
            logger.error(f"Error generating inventory report: {e}")
            return ServiceResult(False, errors=[str(e)])
