#!/usr/bin/env python3
"""
ChaOffice Core - Main Application Entry Point
Hybrid PySide6 QML Business Management System
"""

import sys
import os
from pathlib import Path
from typing import Optional

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType, qmlRegisterType
from PySide6.QtCore import QUrl, QObject
from PySide6.QtGui import QIcon

# Add src to Python path
src_path = Path(__file__).parent
sys.path.insert(0, str(src_path))

from app_logger.log_manager import LogManager
from core.config_manager import ConfigManager
from local_db.local_db_manager import LocalDbManager
from api_client.auth_api_client import AuthApiClient
from api_client.product_api_client import ProductApiClient
from api_client.sync_manager import SyncManager
from business_logic.auth_service import AuthService
from business_logic.product_service import ProductService
from qml_handlers.qml_bridge import QmlBridge


class ChaOfficeApp:
    """Main application class for ChaOffice."""
    
    def __init__(self):
        self.app: Optional[QApplication] = None
        self.engine: Optional[QQmlApplicationEngine] = None
        self.qml_bridge: Optional[QmlBridge] = None
        self.logger = None
        
    def setup_logging(self) -> None:
        """Initialize application logging."""
        log_manager = LogManager()
        self.logger = log_manager.get_logger("ChaOfficeApp")
        self.logger.info("Starting ChaOffice application...")
        
    def setup_services(self) -> None:
        """Initialize all application services."""
        try:
            # Core configuration
            config_manager = ConfigManager()
            
            # Database manager
            db_manager = LocalDbManager()
            
            # API clients
            auth_api = AuthApiClient(config_manager)
            product_api = ProductApiClient(config_manager)
            
            # Sync manager
            sync_manager = SyncManager(db_manager, product_api, config_manager)
            
            # Business logic services
            auth_service = AuthService(config_manager, db_manager, auth_api)
            product_service = ProductService(config_manager, db_manager, product_api)
            
            # QML Bridge
            self.qml_bridge = QmlBridge(
                auth_service=auth_service,
                product_service=product_service,
                config_manager=config_manager
            )
            
            self.logger.info("All services initialized successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize services: {e}")
            raise
    
    def setup_qml_engine(self) -> None:
        """Setup QML engine and register types."""
        try:
            self.engine = QQmlApplicationEngine()
            
            # Register QML Bridge as context property
            self.engine.rootContext().setContextProperty("appBridge", self.qml_bridge)
            
            # Add QML import paths
            qml_path = src_path / "qml"
            self.engine.addImportPath(str(qml_path))
            self.engine.addImportPath("qrc:/")
            
            self.logger.info("QML engine configured successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to setup QML engine: {e}")
            raise
    
    def load_qml(self) -> bool:
        """Load the main QML file."""
        try:
            main_qml = src_path / "qml" / "main.qml"
            if not main_qml.exists():
                self.logger.error(f"Main QML file not found: {main_qml}")
                return False
                
            self.engine.load(QUrl.fromLocalFile(str(main_qml)))
            
            if not self.engine.rootObjects():
                self.logger.error("Failed to load QML - no root objects created")
                return False
                
            self.logger.info("QML loaded successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to load QML: {e}")
            return False
    
    def run(self) -> int:
        """Run the application."""
        try:
            # Initialize Qt Application
            self.app = QApplication(sys.argv)
            self.app.setApplicationName("ChaOffice")
            self.app.setApplicationDisplayName("ChaOffice Core")
            self.app.setApplicationVersion("0.1.0")
            
            # Setup logging first
            self.setup_logging()
            
            # Initialize services
            self.setup_services()
            
            # Setup QML
            self.setup_qml_engine()
            
            # Load QML
            if not self.load_qml():
                return 1
            
            # Run application
            self.logger.info("Application started successfully")
            return self.app.exec()
            
        except Exception as e:
            if self.logger:
                self.logger.error(f"Application startup failed: {e}")
            else:
                print(f"Application startup failed: {e}")
            return 1
        
        finally:
            if self.logger:
                self.logger.info("Application shutting down")


def main() -> int:
    """Main entry point."""
    app = ChaOfficeApp()
    return app.run()


if __name__ == "__main__":
    sys.exit(main())
