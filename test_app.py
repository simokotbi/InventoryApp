#!/usr/bin/env python3
"""
Simple test runner for ChaOffice
"""

import sys
import os
from pathlib import Path

# Add src to Python path
src_path = Path(__file__).parent / "src"
sys.path.insert(0, str(src_path))

def test_imports():
    """Test all imports."""
    print("Testing imports...")
    
    try:
        print("1. Testing PySide6...")
        from PySide6.QtWidgets import QApplication
        from PySide6.QtQml import QQmlApplicationEngine
        from PySide6.QtCore import QUrl
        print("   ✓ PySide6 imports successful")
        
        print("2. Testing app modules...")
        from app_logger.log_manager import LogManager
        from core.config_manager import ConfigManager
        from local_db.local_db_manager import LocalDbManager
        print("   ✓ Core modules imported")
        
        print("3. Testing QML bridge...")
        from qml_handlers.qml_bridge import QmlBridge
        print("   ✓ QML bridge imported")
        
        print("4. Testing business logic...")
        from business_logic.auth_service import AuthService
        from business_logic.product_service import ProductService
        print("   ✓ Business logic imported")
        
        print("All imports successful!")
        return True
        
    except Exception as e:
        print(f"Import failed: {e}")
        return False

def test_initialization():
    """Test basic initialization."""
    print("\nTesting initialization...")
    
    try:
        print("1. Creating QApplication...")
        from PySide6.QtWidgets import QApplication
        app = QApplication(sys.argv)
        print("   ✓ QApplication created")
        
        print("2. Testing config manager...")
        from core.config_manager import ConfigManager
        config = ConfigManager()
        print("   ✓ Config manager created")
        
        print("3. Testing database...")
        from local_db.local_db_manager import LocalDbManager
        db = LocalDbManager()
        print("   ✓ Database manager created")
        
        print("4. Creating QML engine...")
        from PySide6.QtQml import QQmlApplicationEngine
        engine = QQmlApplicationEngine()
        print("   ✓ QML engine created")
        
        print("5. Testing QML file path...")
        qml_path = src_path / "qml" / "main.qml"
        print(f"   QML path: {qml_path}")
        print(f"   QML exists: {qml_path.exists()}")
        
        print("Initialization test completed!")
        return True
        
    except Exception as e:
        print(f"Initialization failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Main test function."""
    print("ChaOffice Test Runner")
    print("=" * 40)
    
    if not test_imports():
        return 1
        
    if not test_initialization():
        return 1
        
    print("\n✓ All tests passed!")
    print("You can now run: uv run python run.py")
    return 0

if __name__ == "__main__":
    sys.exit(main())
