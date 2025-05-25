"""
Initialize local SQLite database with default data.
Creates tables and inserts sample data for development.
"""

import os
import sys
from pathlib import Path
from datetime import datetime
import bcrypt

# Add src directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from local_db.local_db_manager import LocalDbManager
from local_db.models import (
    User, Product, Customer, Sale, SaleItem, 
    InventoryItem, AppSettings
)


def hash_password(password: str) -> str:
    """Hash a password using bcrypt."""
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')


def create_default_users(db_manager: LocalDbManager) -> None:
    """Create default users for testing."""
    print("Creating default users...")
    
    users = [
        User(
            username="admin",
            email="admin@chaoffice.com",
            password_hash=hash_password("admin123"),
            first_name="Admin",
            last_name="User",
            role="admin",
            is_active=True
        ),
        User(
            username="sales",
            email="sales@chaoffice.com",
            password_hash=hash_password("sales123"),
            first_name="Sales",
            last_name="User",
            role="sales",
            is_active=True
        ),
        User(
            username="inventory",
            email="inventory@chaoffice.com",
            password_hash=hash_password("inventory123"),
            first_name="Inventory",            last_name="User",
            role="inventory",
            is_active=True
        )
    ]
    
    for user in users:
        # Check if user already exists
        username = user.username  # Store username before session operations
        existing_user = db_manager.get_user_by_username(username)
        if not existing_user:
            db_manager.create(user)
            print(f"Created user: {username}")
        else:
            print(f"User already exists: {username}")


def create_sample_products(db_manager: LocalDbManager) -> None:
    """Create sample products for testing."""
    print("Creating sample products...")
    
    products = [
        Product(
            name="Laptop Computer",
            description="High-performance laptop for business use",
            sku="LAP-001",
            barcode="123456789012",
            unit_price=999.99,
            cost_price=750.00,
            category="Electronics",
            supplier="Tech Supplier Inc",
            is_active=True
        ),
        Product(
            name="Wireless Mouse",
            description="Ergonomic wireless mouse with USB receiver",
            sku="MSE-001",
            barcode="123456789013",
            unit_price=29.99,
            cost_price=15.00,
            category="Electronics",
            supplier="Tech Supplier Inc",
            is_active=True
        ),
        Product(
            name="Office Chair",
            description="Comfortable ergonomic office chair",
            sku="CHR-001",
            barcode="123456789014",
            unit_price=199.99,
            cost_price=120.00,
            category="Furniture",
            supplier="Furniture Co",
            is_active=True
        ),
        Product(
            name="Notebook Set",
            description="Set of 5 professional notebooks",
            sku="NTB-001",
            barcode="123456789015",
            unit_price=15.99,
            cost_price=8.00,
            category="Stationery",
            supplier="Office Supplies Ltd",
            is_active=True
        ),
        Product(
            name="Desk Lamp",
            description="LED desk lamp with adjustable brightness",
            sku="LMP-001",
            barcode="123456789016",            unit_price=49.99,
            cost_price=25.00,
            category="Electronics",
            supplier="Lighting Solutions",
            is_active=True        )
    ]
    
    for product in products:
        # Check if product already exists
        product_name = product.name  # Store name before session operations
        product_sku = product.sku    # Store SKU before session operations
        existing_product = db_manager.get_product_by_sku(product_sku)
        if not existing_product:
            # Create both product and inventory in a single transaction
            def create_product_with_inventory(session):
                session.add(product)
                session.flush()  # Get the ID without committing
                
                # Create inventory item for the product
                inventory_item = InventoryItem(
                    product_id=product.id,
                    current_stock=100.0,
                    minimum_stock=10.0,
                    maximum_stock=500.0,
                    reorder_point=20.0,
                    location="Warehouse A"
                )
                session.add(inventory_item)
                return product
            
            db_manager.execute_in_transaction(create_product_with_inventory)
            print(f"Created product: {product_name}")
            print(f"Created inventory for: {product_name}")
        else:
            print(f"Product already exists: {product_name}")


def create_sample_customers(db_manager: LocalDbManager) -> None:
    """Create sample customers for testing."""
    print("Creating sample customers...")
    
    customers = [
        Customer(
            first_name="John",
            last_name="Doe",
            email="john.doe@email.com",
            phone="+1-555-0123",
            address="123 Main St",
            city="Anytown",
            postal_code="12345",
            country="USA",
            is_active=True
        ),
        Customer(
            first_name="Jane",
            last_name="Smith",
            email="jane.smith@email.com",
            phone="+1-555-0124",
            address="456 Oak Ave",
            city="Somewhere",
            postal_code="67890",
            country="USA",
            is_active=True
        ),
        Customer(
            first_name="Bob",
            last_name="Johnson",
            email="bob.johnson@email.com",
            phone="+1-555-0125",
            address="789 Pine Rd",
            city="Elsewhere",
            postal_code="54321",
            country="USA",
            is_active=True
        )
    ]    
    for customer in customers:
        # Check if customer already exists
        customer_email = customer.email  # Store email before session operations
        customer_first_name = customer.first_name  # Store names before session operations
        customer_last_name = customer.last_name
        existing_customers = db_manager.search_customers(customer_email)
        if not any(c.email == customer_email for c in existing_customers):
            db_manager.create(customer)
            print(f"Created customer: {customer_first_name} {customer_last_name}")
        else:
            print(f"Customer already exists: {customer_first_name} {customer_last_name}")


def create_default_settings(db_manager: LocalDbManager) -> None:
    """Create default application settings."""
    print("Creating default settings...")
    
    settings = [
        ("app_version", "1.0.0", "Application version"),
        ("currency", "USD", "Default currency"),
        ("tax_rate", "0.08", "Default tax rate (8%)"),
        ("company_name", "ChaoOffice Demo", "Company name"),
        ("company_address", "123 Business St, City, State 12345", "Company address"),
        ("receipt_footer", "Thank you for your business!", "Receipt footer message")
    ]
    
    for key, value, description in settings:
        existing_setting = db_manager.get_setting(key)
        if not existing_setting:
            db_manager.set_setting(key, value, description)
            print(f"Created setting: {key} = {value}")
        else:
            print(f"Setting already exists: {key}")


def initialize_database(database_path: str = "data/chaoffice.db") -> None:
    """Initialize the database with default data."""
    print(f"Initializing database at: {database_path}")
    
    try:
        # Create database manager
        db_manager = LocalDbManager(database_path)
        
        # Create default data
        create_default_users(db_manager)
        create_sample_products(db_manager)
        create_sample_customers(db_manager)
        create_default_settings(db_manager)
        
        print("\nDatabase initialization completed successfully!")
        print("\nDefault login credentials:")
        print("Admin: username=admin, password=admin123")
        print("Sales: username=sales, password=sales123")
        print("Inventory: username=inventory, password=inventory123")
        
    except Exception as e:
        print(f"Error initializing database: {e}")
        raise
    finally:
        if 'db_manager' in locals():
            db_manager.close()


def main():
    """Main function for script execution."""
    # Get database path from environment or use default
    database_path = os.environ.get("CHAOFFICE_DB_PATH", "data/chaoffice.db")
    
    # Check if database already exists
    if os.path.exists(database_path):
        response = input(f"Database {database_path} already exists. Recreate? (y/N): ")
        if response.lower() != 'y':
            print("Database initialization cancelled.")
            return
        
        # Remove existing database
        os.remove(database_path)
        print(f"Removed existing database: {database_path}")
    
    initialize_database(database_path)


if __name__ == "__main__":
    main()
