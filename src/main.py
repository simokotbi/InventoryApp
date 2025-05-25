#!/usr/bin/env python3
"""
ChaoOffice - Modern PySide6 Business Management Application
Main application entry point.
"""

import sys
import os
from pathlib import Path
from typing import Optional
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType, qmlRegisterType
from PySide6.QtCore import QObject, QTimer, QUrl

# Add src directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from app_logging.log_manager import LogManager
from core.config_manager import ConfigManager
from core.navigation_manager import NavigationManager
from local_db.local_db_manager import LocalDbManager
from local_db.init_local_db import initialize_database
from api_client.base_api_client import BaseApiClient
from api_client.auth_api_client import AuthApiClient
from api_client.product_api_client import ProductApiClient
from api_client.customer_api_client import CustomerApiClient
from api_client.sales_api_client import SalesApiClient
from api_client.inventory_api_client import InventoryApiClient
from api_client.sync_manager import SyncManager
from services.auth_service import AuthService
from services.business_services import (
    UserService, ProductService, CustomerService, 
    SalesService, InventoryService, ReportService
)
from qml_handlers.qml_bridge import (
    AuthHandler, ProductHandler, CustomerHandler,
    SalesHandler, InventoryHandler, ReportsHandler, SyncHandler
)
from qml_handlers.theme_manager import ThemeManager

# TODO: Create these missing services and handlers
# from business_logic.product_service import ProductService
# from business_logic.customer_service import CustomerService
# from business_logic.sales_service import SalesService
# from business_logic.inventory_service import InventoryService
# from business_logic.report_service import ReportService
# from authentication.auth_handler import AuthHandler
# from api_handlers.product_handler import ProductHandler
# from api_handlers.customer_handler import CustomerHandler
# from api_handlers.sales_handler import SalesHandler
# from api_handlers.inventory_handler import InventoryHandler
# from api_handlers.report_handler import ReportHandler


class ChaoOfficeApplication:
    """Main application class that orchestrates all components."""
    
    def __init__(self):
        self.app: Optional[QApplication] = None
        self.engine: Optional[QQmlApplicationEngine] = None
        self.log_manager: Optional[LogManager] = None
        self.config_manager: Optional[ConfigManager] = None
        self.navigation_manager: Optional[NavigationManager] = None
        self.local_db_manager: Optional[LocalDbManager] = None
        
        # API Clients
        self.base_api_client: Optional[BaseApiClient] = None
        self.auth_api_client: Optional[AuthApiClient] = None
        self.product_api_client: Optional[ProductApiClient] = None
        self.customer_api_client: Optional[CustomerApiClient] = None
        self.sales_api_client: Optional[SalesApiClient] = None
        self.inventory_api_client: Optional[InventoryApiClient] = None
        self.sync_manager: Optional[SyncManager] = None        # Business Logic Services
        self.auth_service: Optional[AuthService] = None
        self.user_service: Optional[UserService] = None
        self.product_service: Optional[ProductService] = None
        self.customer_service: Optional[CustomerService] = None
        self.sales_service: Optional[SalesService] = None
        self.inventory_service: Optional[InventoryService] = None
        self.report_service: Optional[ReportService] = None
          # QML Handlers
        self.theme_manager: Optional[ThemeManager] = None
        self.auth_handler: Optional[AuthHandler] = None
        self.product_handler: Optional[ProductHandler] = None
        self.customer_handler: Optional[CustomerHandler] = None
        self.sales_handler: Optional[SalesHandler] = None
        self.inventory_handler: Optional[InventoryHandler] = None
        self.reports_handler: Optional[ReportsHandler] = None
        self.sync_handler: Optional[SyncHandler] = None
        # self.product_handler: Optional[ProductHandler] = None
        # self.customer_handler: Optional[CustomerHandler] = None
        # self.sales_handler: Optional[SalesHandler] = None
        # self.inventory_handler: Optional[InventoryHandler] = None
        # self.report_handler: Optional[ReportHandler] = None
    
    def initialize_core_components(self) -> None:
        """Initialize core application components."""
        # Initialize logging first
        self.log_manager = LogManager()
        self.log_manager.setup_logging()
        
        # Initialize configuration
        self.config_manager = ConfigManager()
        self.config_manager.load_config()
        
        # Initialize navigation
        self.navigation_manager = NavigationManager()
        
        # Initialize local database
        self.local_db_manager = LocalDbManager()
        
        # Ensure database is initialized
        if not os.path.exists(self.config_manager.get_database_path()):
            initialize_database()
        
        self.log_manager.logger.info("Core components initialized successfully")
    
    def initialize_api_clients(self) -> None:
        """Initialize API clients for Supabase communication."""
        self.base_api_client = BaseApiClient(self.config_manager)
        self.auth_api_client = AuthApiClient(self.base_api_client)
        self.product_api_client = ProductApiClient(self.base_api_client)
        self.customer_api_client = CustomerApiClient(self.base_api_client)
        self.sales_api_client = SalesApiClient(self.base_api_client)
        self.inventory_api_client = InventoryApiClient(self.base_api_client)
          # Initialize sync manager
        self.sync_manager = SyncManager(
            local_db_manager=self.local_db_manager,
            auth_client=self.auth_api_client,
            product_client=self.product_api_client,
            customer_client=self.customer_api_client,
            sales_client=self.sales_api_client,
            inventory_client=self.inventory_api_client        )
        
        self.log_manager.logger.info("API clients initialized successfully")
    
    def initialize_business_services(self) -> None:
        """Initialize business logic services."""
        self.auth_service = AuthService(
            local_db=self.local_db_manager,
            auth_api_client=self.auth_api_client,
            config_manager=self.config_manager
        )
        
        # Initialize all business services
        self.user_service = UserService(
            local_db=self.local_db_manager,
            sync_manager=self.sync_manager
        )
        
        self.product_service = ProductService(
            local_db=self.local_db_manager,
            sync_manager=self.sync_manager
        )
        
        self.customer_service = CustomerService(
            local_db=self.local_db_manager,
            sync_manager=self.sync_manager
        )
        
        self.sales_service = SalesService(
            local_db=self.local_db_manager,
            sync_manager=self.sync_manager
        )
        
        self.inventory_service = InventoryService(
            local_db=self.local_db_manager,
            sync_manager=self.sync_manager
        )
        
        self.report_service = ReportService(
            local_db=self.local_db_manager        )
        
        self.log_manager.logger.info("Business services initialized successfully")
    
    def initialize_qml_handlers(self) -> None:
        """Initialize QML-Python bridge handlers."""
        self.theme_manager = ThemeManager(self.config_manager)
          # Initialize all handlers with their required services
        self.auth_handler = AuthHandler(self.auth_service)
        self.product_handler = ProductHandler(self.product_service, self.auth_service)
        self.customer_handler = CustomerHandler(self.customer_service, self.auth_service)
        self.sales_handler = SalesHandler(self.sales_service, self.auth_service)
        self.inventory_handler = InventoryHandler(self.inventory_service, self.auth_service)
        self.reports_handler = ReportsHandler(self.report_service, self.auth_service)
        self.sync_handler = SyncHandler(self.sync_manager, self.auth_service)
        
        self.log_manager.logger.info("QML handlers initialized successfully")
    
    def register_qml_types(self) -> None:
        """Register QML types and singletons."""
        # Register Theme singleton
        qml_dir = Path(__file__).parent / "qml"
          # Register Theme singleton
        def create_theme_singleton(engine):
            return self.config_manager
        
        qmlRegisterSingletonType(
            ConfigManager, "AppStyles", 1, 0, "Theme", create_theme_singleton        )
        
        # Add QML import paths for modules
        self.engine.addImportPath(str(qml_dir))
        self.engine.addImportPath(str(qml_dir / "screens"))
        self.engine.addImportPath(str(qml_dir / "views"))
        self.engine.addImportPath(str(qml_dir / "components"))
        
        self.log_manager.logger.info("QML types registered successfully")
    
    def setup_context_properties(self) -> None:
        """Set up QML context properties."""
        root_context = self.engine.rootContext()
          # Register available handlers as context properties
        root_context.setContextProperty("themeManager", self.theme_manager)
        root_context.setContextProperty("authHandler", self.auth_handler)
        root_context.setContextProperty("productHandler", self.product_handler)
        root_context.setContextProperty("customerHandler", self.customer_handler)
        root_context.setContextProperty("salesHandler", self.sales_handler)
        root_context.setContextProperty("inventoryHandler", self.inventory_handler)
        root_context.setContextProperty("reportsHandler", self.reports_handler)
        root_context.setContextProperty("syncHandler", self.sync_handler)
        # root_context.setContextProperty("reportHandler", self.report_handler)
        
        # Register managers as context properties        root_context.setContextProperty("appConfig", self.config_manager)
        root_context.setContextProperty("navigationManager", self.navigation_manager)
        
        self.log_manager.logger.info("QML context properties set up successfully")
    
    def load_main_qml(self) -> None:
        """Load the main QML file."""
        qml_file = Path(__file__).parent / "qml" / "main.qml"
        
        # TODO: Implement authentication check when auth service is working
        # if self.auth_service.is_authenticated():
        #     qml_file = Path(__file__).parent / "qml" / "screens" / "MainApplication.qml"
        # else:
        #     qml_file = Path(__file__).parent / "qml" / "screens" / "LoginScreen.qml"
        
        self.engine.load(QUrl.fromLocalFile(str(qml_file)))
        
        if not self.engine.rootObjects():
            self.log_manager.logger.error("Failed to load QML file")
            sys.exit(-1)
        
        self.log_manager.logger.info(f"Main QML loaded: {qml_file}")
    
    def setup_periodic_sync(self) -> None:
        """Set up periodic synchronization if online."""
        if self.config_manager.is_online:
            sync_timer = QTimer()
            sync_timer.timeout.connect(self.sync_manager.sync_all_data)
            sync_timer.start(300000)  # Sync every 5 minutes
            self.log_manager.logger.info("Periodic sync timer started")
    
    def run(self) -> int:
        """Run the application."""
        try:
            # Initialize Qt Application
            self.app = QApplication(sys.argv)
            self.app.setApplicationName("ChaoOffice")
            self.app.setApplicationVersion("1.0.0")
            self.app.setOrganizationName("ChaoOffice")
            
            # Initialize QML Engine
            self.engine = QQmlApplicationEngine()
            
            # Initialize all components
            self.initialize_core_components()
            self.initialize_api_clients()
            self.initialize_business_services()
            self.initialize_qml_handlers()
            
            # Set up QML
            self.register_qml_types()
            self.setup_context_properties()
            self.load_main_qml()
            
            # Set up periodic sync if online
            self.setup_periodic_sync()
            
            self.log_manager.logger.info("ChaoOffice application started successfully")
            
            # Run the application
            return self.app.exec()
            
        except Exception as e:
            if self.log_manager:
                self.log_manager.logger.error(f"Failed to start application: {e}")
            else:
                print(f"Failed to start application: {e}")
            return -1
    
    def cleanup(self) -> None:
        """Clean up resources before exit."""
        if self.local_db_manager:
            self.local_db_manager.close()
        
        if self.log_manager:
            self.log_manager.logger.info("ChaoOffice application shutting down")


def main() -> int:
    """Main entry point."""
    app = ChaoOfficeApplication()
    exit_code = app.run()
    app.cleanup()
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
