#!/usr/bin/env python3
"""
Script to initialize local SQLite database with sample data.
"""

import sys
from pathlib import Path

# Add src to Python path
src_path = Path(__file__).parent.parent
sys.path.insert(0, str(src_path))

from local_db.local_db_manager import LocalDbManager
from app_logger.log_manager import LogManager


def init_local_db():
    """Initialize local database with sample data."""
    logger = LogManager().get_logger("InitLocalDb")
    logger.info("Starting local database initialization...")
    
    try:
        # Initialize database manager
        db_manager = LocalDbManager()
        
        # Create default admin user
        admin_user = db_manager.create_user(
            email="admin@example.com",
            password="password123",
            full_name="System Administrator"
        )
        
        if admin_user:
            logger.info("Default admin user created successfully")
        else:
            logger.warning("Admin user may already exist")
        
        # Create sample products
        sample_products = [
            {
                "name": "Wireless Bluetooth Headphones",
                "description": "High-quality wireless headphones with noise cancellation",
                "price": 9999,  # $99.99 in cents
                "sku": "WBH-001",
                "category": "Electronics",
                "stock_quantity": 50
            },
            {
                "name": "Ergonomic Office Chair",
                "description": "Comfortable office chair with lumbar support",
                "price": 24999,  # $249.99 in cents
                "sku": "EOC-002",
                "category": "Furniture",
                "stock_quantity": 15
            },
            {
                "name": "Stainless Steel Water Bottle",
                "description": "Insulated water bottle that keeps drinks cold for 24 hours",
                "price": 2499,  # $24.99 in cents
                "sku": "SSWB-003",
                "category": "Lifestyle",
                "stock_quantity": 100
            },
            {
                "name": "Professional Coffee Maker",
                "description": "Programmable coffee maker with thermal carafe",
                "price": 12999,  # $129.99 in cents
                "sku": "PCM-004",
                "category": "Appliances",
                "stock_quantity": 25
            },
            {
                "name": "Smart Fitness Watch",
                "description": "Fitness tracker with heart rate monitor and GPS",
                "price": 19999,  # $199.99 in cents
                "sku": "SFW-005",
                "category": "Electronics",
                "stock_quantity": 75
            }
        ]
        
        created_count = 0
        for product_data in sample_products:
            product = db_manager.create_product(**product_data)
            if product:
                created_count += 1
        
        logger.info(f"Created {created_count} sample products")
        
        # Display database info
        db_info = db_manager.get_database_info()
        logger.info(f"Database initialization complete:")
        logger.info(f"  - Database file: {db_info.get('database_file')}")
        logger.info(f"  - Users: {db_info.get('user_count')}")
        logger.info(f"  - Products: {db_info.get('product_count')}")
        
        print("\n" + "="*50)
        print("DATABASE INITIALIZATION COMPLETE")
        print("="*50)
        print(f"Default login credentials:")
        print(f"  Email: admin@example.com")
        print(f"  Password: password123")
        print(f"\nDatabase location: {db_info.get('database_file')}")
        print(f"Total products created: {db_info.get('product_count')}")
        print("="*50)
        
    except Exception as e:
        logger.error(f"Database initialization failed: {e}")
        print(f"Error: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(init_local_db())
