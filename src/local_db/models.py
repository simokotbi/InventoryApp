"""
SQLAlchemy ORM models for the ChaoOffice application.
These models mirror the Supabase table schemas for consistent synchronization.
"""

from datetime import datetime
from typing import Optional
from sqlalchemy import (
    Column, Integer, String, Float, Boolean, DateTime, Text, 
    ForeignKey, Table, create_engine, MetaData
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.sql import func

Base = declarative_base()


class User(Base):
    """User model for authentication and role management."""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    role = Column(String(20), nullable=False, default="sales")  # admin, sales, inventory
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)  # create, update, delete
    supabase_id = Column(String(100), nullable=True)  # Supabase UUID
    
    # Relationships
    sales = relationship("Sale", back_populates="user")


class Product(Base):
    """Product model for inventory management."""
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    sku = Column(String(50), unique=True, nullable=False)
    barcode = Column(String(100), nullable=True)
    unit_price = Column(Float, nullable=False)
    cost_price = Column(Float, nullable=False)
    category = Column(String(50), nullable=True)
    supplier = Column(String(100), nullable=True)
    image_url = Column(String(255), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)
    supabase_id = Column(String(100), nullable=True)
    
    # Relationships
    inventory_items = relationship("InventoryItem", back_populates="product")
    sale_items = relationship("SaleItem", back_populates="product")


class Customer(Base):
    """Customer model for customer management."""
    __tablename__ = "customers"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    email = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    address = Column(Text, nullable=True)
    city = Column(String(50), nullable=True)
    postal_code = Column(String(20), nullable=True)
    country = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)
    supabase_id = Column(String(100), nullable=True)
    
    # Relationships
    sales = relationship("Sale", back_populates="customer")


class Sale(Base):
    """Sale model for transaction management."""
    __tablename__ = "sales"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    sale_number = Column(String(50), unique=True, nullable=False)
    customer_id = Column(Integer, ForeignKey("customers.id"), nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    subtotal = Column(Float, nullable=False, default=0.0)
    tax_amount = Column(Float, nullable=False, default=0.0)
    discount_amount = Column(Float, nullable=False, default=0.0)
    total_amount = Column(Float, nullable=False, default=0.0)
    payment_status = Column(String(20), nullable=False, default="pending")  # pending, paid, refunded
    payment_method = Column(String(20), nullable=True)  # cash, card, bank_transfer
    notes = Column(Text, nullable=True)
    sale_date = Column(DateTime, default=func.now())
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)
    supabase_id = Column(String(100), nullable=True)
    
    # Relationships
    customer = relationship("Customer", back_populates="sales")
    user = relationship("User", back_populates="sales")
    sale_items = relationship("SaleItem", back_populates="sale", cascade="all, delete-orphan")


class SaleItem(Base):
    """Sale item model for individual product sales."""
    __tablename__ = "sale_items"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    sale_id = Column(Integer, ForeignKey("sales.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    quantity = Column(Float, nullable=False)
    unit_price = Column(Float, nullable=False)
    discount_amount = Column(Float, nullable=False, default=0.0)
    total_amount = Column(Float, nullable=False)
    created_at = Column(DateTime, default=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)
    supabase_id = Column(String(100), nullable=True)
    
    # Relationships
    sale = relationship("Sale", back_populates="sale_items")
    product = relationship("Product", back_populates="sale_items")


class InventoryItem(Base):
    """Inventory model for stock management."""
    __tablename__ = "inventory"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    current_stock = Column(Float, nullable=False, default=0.0)
    minimum_stock = Column(Float, nullable=False, default=0.0)
    maximum_stock = Column(Float, nullable=True)
    reorder_point = Column(Float, nullable=True)
    location = Column(String(50), nullable=True)
    last_restocked = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)
    supabase_id = Column(String(100), nullable=True)
    
    # Relationships
    product = relationship("Product", back_populates="inventory_items")
    movements = relationship("InventoryMovement", back_populates="inventory_item")


class InventoryMovement(Base):
    """Inventory movement model for tracking stock changes."""
    __tablename__ = "inventory_movements"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    inventory_id = Column(Integer, ForeignKey("inventory.id"), nullable=False)
    movement_type = Column(String(20), nullable=False)  # in, out, adjustment
    quantity = Column(Float, nullable=False)
    previous_stock = Column(Float, nullable=False)
    new_stock = Column(Float, nullable=False)
    reason = Column(String(100), nullable=True)
    reference_id = Column(String(50), nullable=True)  # Sale ID, Purchase Order, etc.
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    movement_date = Column(DateTime, default=func.now())
    created_at = Column(DateTime, default=func.now())
    
    # Sync fields
    is_synced = Column(Boolean, default=False)
    action_pending = Column(String(10), nullable=True)
    supabase_id = Column(String(100), nullable=True)
    
    # Relationships
    inventory_item = relationship("InventoryItem", back_populates="movements")


class AppSettings(Base):
    """Application settings model."""
    __tablename__ = "app_settings"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    key = Column(String(100), unique=True, nullable=False)
    value = Column(Text, nullable=True)
    description = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())


# Utility functions
def create_tables(engine):
    """Create all tables in the database."""
    Base.metadata.create_all(engine)


def get_session_factory(database_url: str):
    """Create a session factory for the given database URL."""
    engine = create_engine(database_url, echo=False)
    create_tables(engine)
    return sessionmaker(bind=engine)
