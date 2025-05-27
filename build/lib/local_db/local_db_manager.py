"""
SQLAlchemy ORM manager for local SQLite database operations.
"""

from pathlib import Path
from typing import List, Optional, Dict, Any
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.exc import SQLAlchemyError
import bcrypt

from .models import Base, User, Product
from app_logger.log_manager import LogManager


class LocalDbManager:
    """Manages local SQLite database operations using SQLAlchemy ORM."""
    
    def __init__(self, database_file: str = "instance/chaoffice.db"):
        """Initialize database manager."""
        self.logger = LogManager().get_logger("LocalDbManager")
        self.database_file = Path(database_file)
        
        # Ensure database directory exists
        self.database_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Create database engine
        self.engine = create_engine(
            f"sqlite:///{self.database_file}",
            echo=False,  # Set to True for SQL debugging
            pool_pre_ping=True,
            connect_args={"check_same_thread": False}
        )
        
        # Create session factory
        self.SessionLocal = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=self.engine
        )
        
        # Create tables
        self._create_tables()
        
        self.logger.info(f"Local database initialized at {self.database_file}")
    
    def _create_tables(self) -> None:
        """Create database tables."""
        try:
            Base.metadata.create_all(bind=self.engine)
            self.logger.info("Database tables created/verified")
        except Exception as e:
            self.logger.error(f"Failed to create tables: {e}")
            raise
    
    def get_session(self) -> Session:
        """Get a new database session."""
        return self.SessionLocal()
    
    def _hash_password(self, password: str) -> str:
        """Hash password using bcrypt."""
        return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    def _verify_password(self, password: str, hashed: str) -> bool:
        """Verify password against hash."""
        return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
    
    # User operations
    def create_user(self, email: str, password: str, full_name: str = "") -> Optional[User]:
        """Create a new user."""
        try:
            with self.get_session() as session:
                # Check if user exists
                existing_user = session.query(User).filter(User.email == email).first()
                if existing_user:
                    self.logger.warning(f"User with email {email} already exists")
                    return None
                
                # Create new user
                password_hash = self._hash_password(password)
                user = User(
                    email=email,
                    password_hash=password_hash,
                    full_name=full_name
                )
                
                session.add(user)
                session.commit()
                session.refresh(user)
                
                self.logger.info(f"User created: {email}")
                return user
                
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to create user: {e}")
            return None
    
    def get_user_by_credentials(self, email: str, password: str) -> Optional[User]:
        """Authenticate user by email and password."""
        try:
            with self.get_session() as session:
                user = session.query(User).filter(User.email == email).first()
                
                if user and self._verify_password(password, user.password_hash):
                    self.logger.info(f"User authenticated: {email}")
                    return user
                
                self.logger.warning(f"Authentication failed for: {email}")
                return None
                
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to authenticate user: {e}")
            return None
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        try:
            with self.get_session() as session:
                return session.query(User).filter(User.email == email).first()
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to get user by email: {e}")
            return None
    
    # Product operations
    def create_product(self, name: str, description: str = "", price: int = 0, 
                      sku: str = "", category: str = "", stock_quantity: int = 0) -> Optional[Product]:
        """Create a new product."""
        try:
            with self.get_session() as session:
                product = Product(
                    name=name,
                    description=description,
                    price=price,
                    sku=sku,
                    category=category,
                    stock_quantity=stock_quantity
                )
                
                session.add(product)
                session.commit()
                session.refresh(product)
                
                self.logger.info(f"Product created: {name}")
                return product
                
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to create product: {e}")
            return None
    
    def get_all_products(self) -> List[Product]:
        """Get all products."""
        try:
            with self.get_session() as session:
                products = session.query(Product).all()
                self.logger.info(f"Retrieved {len(products)} products")
                return products
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to get products: {e}")
            return []
    
    def get_product_by_id(self, product_id: int) -> Optional[Product]:
        """Get product by ID."""
        try:
            with self.get_session() as session:
                return session.query(Product).filter(Product.id == product_id).first()
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to get product by ID: {e}")
            return None
    
    def update_product(self, product_id: int, **kwargs) -> Optional[Product]:
        """Update product."""
        try:
            with self.get_session() as session:
                product = session.query(Product).filter(Product.id == product_id).first()
                if not product:
                    return None
                
                for key, value in kwargs.items():
                    if hasattr(product, key):
                        setattr(product, key, value)
                
                session.commit()
                session.refresh(product)
                
                self.logger.info(f"Product updated: {product_id}")
                return product
                
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to update product: {e}")
            return None
    
    def delete_product(self, product_id: int) -> bool:
        """Delete product."""
        try:
            with self.get_session() as session:
                product = session.query(Product).filter(Product.id == product_id).first()
                if not product:
                    return False
                
                session.delete(product)
                session.commit()
                
                self.logger.info(f"Product deleted: {product_id}")
                return True
                
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to delete product: {e}")
            return False
    
    # Utility methods
    def get_database_info(self) -> Dict[str, Any]:
        """Get database information."""
        try:
            with self.get_session() as session:
                user_count = session.query(User).count()
                product_count = session.query(Product).count()
                
                return {
                    'database_file': str(self.database_file),
                    'user_count': user_count,
                    'product_count': product_count,
                    'tables': ['users', 'products']
                }
        except SQLAlchemyError as e:
            self.logger.error(f"Failed to get database info: {e}")
            return {}
    
    def close(self) -> None:
        """Close database connections."""
        try:
            self.engine.dispose()
            self.logger.info("Database connections closed")
        except Exception as e:
            self.logger.error(f"Error closing database: {e}")
