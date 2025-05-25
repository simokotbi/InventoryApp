"""
Local database manager using SQLAlchemy for SQLite operations.
Handles database connections, transactions, and CRUD operations.
"""

import os
from pathlib import Path
from typing import Optional, List, Dict, Any, Type, TypeVar
from sqlalchemy import create_engine, and_, or_
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.exc import SQLAlchemyError

from .models import (
    Base, User, Product, Customer, Sale, SaleItem, 
    InventoryItem, InventoryMovement, AppSettings
)

T = TypeVar('T', bound=Base)


class LocalDbManager:
    """Manages local SQLite database operations."""
    
    def __init__(self, database_path: str = "data/chaoffice.db"):
        self.database_path = database_path
        self.engine = None
        self.session_factory = None
        self._current_session: Optional[Session] = None
        self._initialize_database()
    
    def _initialize_database(self) -> None:
        """Initialize the database connection and create tables."""
        try:
            # Ensure database directory exists
            db_dir = Path(self.database_path).parent
            db_dir.mkdir(parents=True, exist_ok=True)
            
            # Create engine
            database_url = f"sqlite:///{self.database_path}"
            self.engine = create_engine(database_url, echo=False)
            
            # Create tables
            Base.metadata.create_all(self.engine)
            
            # Create session factory
            self.session_factory = sessionmaker(bind=self.engine)
            
        except Exception as e:
            raise RuntimeError(f"Failed to initialize database: {e}")
    
    def get_session(self) -> Session:
        """Get a new database session."""
        if not self.session_factory:
            raise RuntimeError("Database not initialized")
        return self.session_factory()
    
    def begin_transaction(self) -> Session:
        """Begin a new transaction and return the session."""
        if self._current_session:
            raise RuntimeError("Transaction already in progress")
        
        self._current_session = self.get_session()
        return self._current_session
    
    def commit_transaction(self) -> None:
        """Commit the current transaction."""
        if not self._current_session:
            raise RuntimeError("No transaction in progress")
        
        try:
            self._current_session.commit()
        finally:
            self._current_session.close()
            self._current_session = None
    
    def rollback_transaction(self) -> None:
        """Rollback the current transaction."""
        if not self._current_session:
            raise RuntimeError("No transaction in progress")
        
        try:
            self._current_session.rollback()
        finally:
            self._current_session.close()
            self._current_session = None
    
    def execute_in_transaction(self, func, *args, **kwargs):
        """Execute a function within a transaction."""
        session = self.begin_transaction()
        try:
            result = func(session, *args, **kwargs)
            self.commit_transaction()
            return result
        except Exception:
            self.rollback_transaction()
            raise
    
    # Generic CRUD operations
    def create(self, model_instance: T) -> T:
        """Create a new record."""
        def _create(session: Session) -> T:
            session.add(model_instance)
            session.flush()  # Get the ID without committing
            session.refresh(model_instance)
            return model_instance
        
        return self.execute_in_transaction(_create)
    
    def get_by_id(self, model_class: Type[T], record_id: int) -> Optional[T]:
        """Get a record by ID."""
        with self.get_session() as session:
            return session.query(model_class).filter(model_class.id == record_id).first()
    
    def get_all(self, model_class: Type[T], filters: Optional[Dict[str, Any]] = None) -> List[T]:
        """Get all records with optional filters."""
        with self.get_session() as session:
            query = session.query(model_class)
            
            if filters:
                for key, value in filters.items():
                    if hasattr(model_class, key):
                        query = query.filter(getattr(model_class, key) == value)
            
            return query.all()
    
    def update(self, model_instance: T) -> T:
        """Update an existing record."""
        def _update(session: Session) -> T:
            session.merge(model_instance)
            session.flush()
            session.refresh(model_instance)
            return model_instance
        
        return self.execute_in_transaction(_update)
    
    def delete(self, model_class: Type[T], record_id: int) -> bool:
        """Delete a record by ID."""
        def _delete(session: Session) -> bool:
            record = session.query(model_class).filter(model_class.id == record_id).first()
            if record:
                session.delete(record)
                return True
            return False
        
        return self.execute_in_transaction(_delete)
    
    # User operations
    def get_user_by_username(self, username: str) -> Optional[User]:
        """Get user by username."""
        with self.get_session() as session:
            return session.query(User).filter(User.username == username).first()
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        with self.get_session() as session:
            return session.query(User).filter(User.email == email).first()
    
    # Product operations
    def get_product_by_sku(self, sku: str) -> Optional[Product]:
        """Get product by SKU."""
        with self.get_session() as session:
            return session.query(Product).filter(Product.sku == sku).first()
    
    def search_products(self, search_term: str) -> List[Product]:
        """Search products by name, SKU, or description."""
        with self.get_session() as session:
            search_pattern = f"%{search_term}%"
            return session.query(Product).filter(
                or_(
                    Product.name.ilike(search_pattern),
                    Product.sku.ilike(search_pattern),
                    Product.description.ilike(search_pattern)
                )
            ).all()
    
    # Customer operations
    def search_customers(self, search_term: str) -> List[Customer]:
        """Search customers by name, email, or phone."""
        with self.get_session() as session:
            search_pattern = f"%{search_term}%"
            return session.query(Customer).filter(
                or_(
                    Customer.first_name.ilike(search_pattern),
                    Customer.last_name.ilike(search_pattern),
                    Customer.email.ilike(search_pattern),
                    Customer.phone.ilike(search_pattern)
                )
            ).all()
    
    # Sale operations
    def get_sales_by_customer(self, customer_id: int) -> List[Sale]:
        """Get all sales for a customer."""
        with self.get_session() as session:
            return session.query(Sale).filter(Sale.customer_id == customer_id).all()
    
    def get_sales_by_date_range(self, start_date, end_date) -> List[Sale]:
        """Get sales within a date range."""
        with self.get_session() as session:
            return session.query(Sale).filter(
                and_(
                    Sale.sale_date >= start_date,
                    Sale.sale_date <= end_date
                )
            ).all()
    
    def generate_sale_number(self) -> str:
        """Generate a unique sale number."""
        with self.get_session() as session:
            # Get the latest sale number
            latest_sale = session.query(Sale).order_by(Sale.id.desc()).first()
            if latest_sale:
                # Extract number from sale_number (format: SALE-XXXX)
                try:
                    number = int(latest_sale.sale_number.split('-')[1]) + 1
                except (IndexError, ValueError):
                    number = 1
            else:
                number = 1
            
            return f"SALE-{number:04d}"
    
    # Inventory operations
    def get_inventory_by_product(self, product_id: int) -> Optional[InventoryItem]:
        """Get inventory item for a product."""
        with self.get_session() as session:
            return session.query(InventoryItem).filter(
                InventoryItem.product_id == product_id
            ).first()
    
    def get_low_stock_items(self) -> List[InventoryItem]:
        """Get inventory items with stock below minimum."""
        with self.get_session() as session:
            return session.query(InventoryItem).filter(
                InventoryItem.current_stock <= InventoryItem.minimum_stock
            ).all()
    
    def update_stock(self, product_id: int, quantity_change: float, 
                    movement_type: str, reason: str = "", reference_id: str = "") -> bool:
        """Update stock and create movement record."""
        def _update_stock(session: Session) -> bool:
            # Get or create inventory item
            inventory_item = session.query(InventoryItem).filter(
                InventoryItem.product_id == product_id
            ).first()
            
            if not inventory_item:
                # Create new inventory item
                inventory_item = InventoryItem(
                    product_id=product_id,
                    current_stock=0.0,
                    minimum_stock=0.0
                )
                session.add(inventory_item)
                session.flush()
            
            # Calculate new stock
            previous_stock = inventory_item.current_stock
            new_stock = previous_stock + quantity_change
            
            # Prevent negative stock for 'out' movements
            if movement_type == "out" and new_stock < 0:
                return False
            
            # Update inventory
            inventory_item.current_stock = new_stock
            inventory_item.is_synced = False
            inventory_item.action_pending = "update"
            
            # Create movement record
            movement = InventoryMovement(
                inventory_id=inventory_item.id,
                movement_type=movement_type,
                quantity=abs(quantity_change),
                previous_stock=previous_stock,
                new_stock=new_stock,
                reason=reason,
                reference_id=reference_id
            )
            session.add(movement)
            
            return True
        
        return self.execute_in_transaction(_update_stock)
    
    # Sync operations
    def get_unsynced_records(self, model_class: Type[T]) -> List[T]:
        """Get all unsynced records for a model."""
        with self.get_session() as session:
            return session.query(model_class).filter(
                model_class.is_synced == False
            ).all()
    
    def mark_as_synced(self, model_instance: T) -> None:
        """Mark a record as synced."""
        def _mark_synced(session: Session) -> None:
            model_instance.is_synced = True
            model_instance.action_pending = None
            session.merge(model_instance)
        
        self.execute_in_transaction(_mark_synced)
    
    # Settings operations
    def get_setting(self, key: str) -> Optional[str]:
        """Get application setting value."""
        with self.get_session() as session:
            setting = session.query(AppSettings).filter(AppSettings.key == key).first()
            return setting.value if setting else None
    
    def set_setting(self, key: str, value: str, description: str = "") -> None:
        """Set application setting value."""
        def _set_setting(session: Session) -> None:
            setting = session.query(AppSettings).filter(AppSettings.key == key).first()
            if setting:
                setting.value = value
                setting.description = description
            else:
                setting = AppSettings(key=key, value=value, description=description)
                session.add(setting)
        
        self.execute_in_transaction(_set_setting)
    
    def close(self) -> None:
        """Close the database connection."""
        if self._current_session:
            self._current_session.close()
        
        if self.engine:
            self.engine.dispose()
