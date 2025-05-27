"""
QML Bridge - Central Python-QML communication layer.
Exposes AuthHandler, ProductHandler, and ConfigHandler to QML.
"""

from typing import Dict, Any, List, Optional
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from PySide6.QtQml import QmlElement

from business_logic.auth_service import AuthService
from business_logic.product_service import ProductService
from core.config_manager import ConfigManager
from app_logger.log_manager import LogManager


QML_IMPORT_NAME = "ChaOffice"
QML_IMPORT_MAJOR_VERSION = 1


class AuthHandler(QObject):
    """Handles authentication operations for QML."""
    
    # Signals
    loginSuccess = Signal()
    loginFailed = Signal(str)
    loggedOut = Signal()
    isLoggedInChanged = Signal()
    
    def __init__(self, auth_service: AuthService, parent=None):
        """Initialize auth handler."""
        super().__init__(parent)
        self.logger = LogManager().get_logger("AuthHandler")
        self.auth_service = auth_service
        self._is_logged_in = False
        self._current_user_data = {}
        
        # Check initial login state
        self._update_login_state()
    
    def _update_login_state(self):
        """Update login state from auth service."""
        new_logged_in = self.auth_service.is_logged_in()
        if new_logged_in != self._is_logged_in:
            self._is_logged_in = new_logged_in
            
            if self._is_logged_in:
                user_data = self.auth_service.get_current_user()
                self._current_user_data = user_data or {}
            else:
                self._current_user_data = {}
                
            self.isLoggedInChanged.emit()
    
    @Property(bool, notify=isLoggedInChanged)
    def isLoggedIn(self) -> bool:
        """Get login status."""
        return self._is_logged_in
    
    @Property(str, notify=isLoggedInChanged)
    def userEmail(self) -> str:
        """Get current user email."""
        return self._current_user_data.get('email', '')
    
    @Property(str, notify=isLoggedInChanged)
    def userFullName(self) -> str:
        """Get current user full name."""
        return self._current_user_data.get('full_name', '')
    
    @Slot(str, str)
    def login(self, email: str, password: str) -> None:
        """Perform user login."""
        try:
            self.logger.info(f"Login attempt for: {email}")
            
            success, message, user_data = self.auth_service.login(email, password)
            
            if success:
                self._update_login_state()
                self.loginSuccess.emit()
                self.logger.info(f"Login successful for: {email}")
            else:
                self.loginFailed.emit(message)
                self.logger.warning(f"Login failed for {email}: {message}")
                
        except Exception as e:
            error_msg = f"Login error: {e}"
            self.logger.error(error_msg)
            self.loginFailed.emit(error_msg)
    
    @Slot()
    def logout(self) -> None:
        """Perform user logout."""
        try:
            self.logger.info("Logout requested")
            
            success, message = self.auth_service.logout()
            
            if success:
                self._update_login_state()
                self.loggedOut.emit()
                self.logger.info("Logout successful")
            else:
                self.logger.error(f"Logout failed: {message}")
                # Still emit loggedOut to clear UI state
                self._update_login_state()
                self.loggedOut.emit()
                
        except Exception as e:
            error_msg = f"Logout error: {e}"
            self.logger.error(error_msg)
            # Still emit loggedOut to clear UI state
            self._update_login_state()
            self.loggedOut.emit()


class ProductHandler(QObject):
    """Handles product operations for QML."""
      # Signals
    productListChanged = Signal()
    productsFetched = Signal()
    productsFetchFailed = Signal(str)
    productOperationComplete = Signal(str)  # For general operations
    
    def __init__(self, product_service: ProductService, auth_service: AuthService, parent=None):
        """Initialize product handler."""
        super().__init__(parent)
        self.logger = LogManager().get_logger("ProductHandler")
        self.product_service = product_service
        self.auth_service = auth_service
        self._product_list: List[Dict[str, Any]] = []
        self._is_loading = False
    
    @Property(list, notify=productListChanged)
    def productList(self) -> List[Dict[str, Any]]:
        """Get current product list."""
        return self._product_list
    
    @Property(bool, notify=productListChanged)
    def isLoading(self) -> bool:
        """Get loading status."""
        return self._is_loading
    
    @Property(int, notify=productListChanged)
    def productCount(self) -> int:
        """Get product count."""
        return len(self._product_list)
    
    @Slot()
    def fetchProducts(self) -> None:
        """Fetch products from service."""
        try:
            self.logger.info("Fetching products")
            self._is_loading = True
            self.productListChanged.emit()
            
            # Get JWT token if available
            jwt_token = self.auth_service.get_jwt_token()
            
            success, message, products = self.product_service.get_products(jwt_token)
            
            self._is_loading = False
            
            if success:
                self._product_list = products
                self.productListChanged.emit()
                self.productsFetched.emit()
                self.logger.info(f"Successfully fetched {len(products)} products")
            else:
                self.productsFetchFailed.emit(message)
                self.logger.error(f"Failed to fetch products: {message}")
                
        except Exception as e:
            self._is_loading = False
            error_msg = f"Error fetching products: {e}"
            self.logger.error(error_msg)
            self.productsFetchFailed.emit(error_msg)
            self.productListChanged.emit()
    
    @Slot(str)
    def searchProducts(self, query: str) -> None:
        """Search products by query."""
        try:
            self.logger.info(f"Searching products: {query}")
            self._is_loading = True
            self.productListChanged.emit()
            
            jwt_token = self.auth_service.get_jwt_token()
            
            if query.strip():
                success, message, products = self.product_service.search_products(query, jwt_token)
            else:
                # Empty query - return all products
                success, message, products = self.product_service.get_products(jwt_token)
            
            self._is_loading = False
            
            if success:
                self._product_list = products
                self.productListChanged.emit()
                self.productOperationComplete.emit(f"Search returned {len(products)} results")
            else:
                self.productsFetchFailed.emit(message)
                self.logger.error(f"Product search failed: {message}")
                
        except Exception as e:
            self._is_loading = False
            error_msg = f"Product search error: {e}"
            self.logger.error(error_msg)
            self.productsFetchFailed.emit(error_msg)
            self.productListChanged.emit()
    
    @Slot(str)
    def filterByCategory(self, category: str) -> None:
        """Filter products by category."""
        try:
            self.logger.info(f"Filtering by category: {category}")
            self._is_loading = True
            self.productListChanged.emit()
            
            jwt_token = self.auth_service.get_jwt_token()
            
            if category.strip() and category.lower() != "all":
                success, message, products = self.product_service.get_products_by_category(category, jwt_token)
            else:
                # "All" category - return all products
                success, message, products = self.product_service.get_products(jwt_token)
            
            self._is_loading = False
            
            if success:
                self._product_list = products
                self.productListChanged.emit()
                self.productOperationComplete.emit(f"Category filter returned {len(products)} products")
            else:
                self.productsFetchFailed.emit(message)
                
        except Exception as e:
            self._is_loading = False
            error_msg = f"Category filter error: {e}"
            self.logger.error(error_msg)
            self.productsFetchFailed.emit(error_msg)
            self.productListChanged.emit()
    @Slot(int, result=dict)
    def getProductById(self, productId: int) -> Optional[Dict[str, Any]]:
        """Get a specific product by ID."""
        try:
            jwt_token = self.auth_service.get_jwt_token()
            success, message, product = self.product_service.get_product_by_id(productId, jwt_token)
            
            if success:
                return product
            else:
                self.logger.warning(f"Product {productId} not found: {message}")
                return None
                
        except Exception as e:
            self.logger.error(f"Error getting product {productId}: {e}")
            return None


class ConfigHandler(QObject):
    """Handles configuration operations for QML."""
    
    # Signals
    isOnlineChanged = Signal()
    themeColorsChanged = Signal()
    configChanged = Signal()
    
    def __init__(self, config_manager: ConfigManager, parent=None):
        """Initialize config handler."""
        super().__init__(parent)
        self.logger = LogManager().get_logger("ConfigHandler")
        self.config_manager = config_manager
    
    @Property(bool, notify=isOnlineChanged)
    def isOnline(self) -> bool:
        """Get online mode status."""
        return self.config_manager.is_online
    
    @Property(str, notify=themeColorsChanged)
    def currentTheme(self) -> str:
        """Get current theme."""
        return self.config_manager.theme
    @Property(dict, notify=themeColorsChanged)
    def themeColors(self) -> Dict[str, str]:
        """Get theme color palette."""
        if self.config_manager.theme == "dark":
            return {
                'primary': '#2196F3',
                'primaryDark': '#1976D2',
                'secondary': '#FF9800',
                'background': '#121212',
                'surface': '#1E1E1E',
                'text': '#FFFFFF',
                'textSecondary': '#BBBBBB',
                'border': '#333333',
                'success': '#4CAF50',
                'warning': '#FF9800',
                'error': '#F44336'
            }
        else:
            return {
                'primary': '#2196F3',
                'primaryDark': '#1976D2',
                'secondary': '#FF9800',
                'background': '#FFFFFF',
                'surface': '#F5F5F5',
                'text': '#212121',
                'textSecondary': '#757575',
                'border': '#E0E0E0',
                'success': '#4CAF50',
                'warning': '#FF9800',
                'error': '#F44336'
            }
    
    @Slot(bool)
    def toggleOnlineMode(self, online: bool) -> None:
        """Toggle online/offline mode."""
        try:
            self.logger.info(f"Toggling online mode to: {online}")
            self.config_manager.is_online = online
            self.isOnlineChanged.emit()
            self.configChanged.emit()
            
        except Exception as e:
            self.logger.error(f"Failed to toggle online mode: {e}")
    
    @Slot()
    def toggleTheme(self) -> None:
        """Toggle between light and dark theme."""
        try:
            new_theme = self.config_manager.toggle_theme()
            self.logger.info(f"Theme toggled to: {new_theme}")
            self.themeColorsChanged.emit()
            self.configChanged.emit()
            
        except Exception as e:
            self.logger.error(f"Failed to toggle theme: {e}")
    
    @Slot(str)
    def setTheme(self, theme: str) -> None:
        """Set specific theme."""
        try:
            if theme in ["light", "dark"]:
                self.config_manager.theme = theme
                self.logger.info(f"Theme set to: {theme}")
                self.themeColorsChanged.emit()
                self.configChanged.emit()
            else:
                self.logger.warning(f"Invalid theme: {theme}")
                
        except Exception as e:
            self.logger.error(f"Failed to set theme: {e}")


@QmlElement
class QmlBridge(QObject):
    """Central QML bridge exposing all handlers."""
    
    def __init__(self, auth_service: AuthService, product_service: ProductService, config_manager: ConfigManager, parent=None):
        """Initialize QML bridge."""
        super().__init__(parent)
        self.logger = LogManager().get_logger("QmlBridge")
        
        # Create handlers
        self._auth_handler = AuthHandler(auth_service, self)
        self._product_handler = ProductHandler(product_service, auth_service, self)
        self._config_handler = ConfigHandler(config_manager, self)
        
        self.logger.info("QML Bridge initialized successfully")
    
    @Property(QObject, constant=True)
    def authHandler(self) -> AuthHandler:
        """Get authentication handler."""
        return self._auth_handler
    
    @Property(QObject, constant=True)
    def productHandler(self) -> ProductHandler:
        """Get product handler."""
        return self._product_handler
    
    @Property(QObject, constant=True)
    def configHandler(self) -> ConfigHandler:
        """Get configuration handler."""
        return self._config_handler
