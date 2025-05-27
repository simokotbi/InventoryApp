#!/usr/bin/env python3
"""
Final verification script for ChaOffice application
"""

import sys
import os
from pathlib import Path

def verify_project_structure():
    """Verify all necessary files exist."""
    print("Verifying project structure...")
    
    required_files = [
        "pyproject.toml",
        "instance_settings.json", 
        "run.py",
        "src/main.py",
        "src/qml/main.qml",
        "src/qml/styles/Theme.qml",
        "src/qml/components/CustomButton.qml",
        "src/qml/components/CustomInput.qml",
        "src/qml/screens/LoadingScreen.qml",
        "src/qml/screens/LoginScreen.qml", 
        "src/qml/screens/MainApplication.qml",
        "src/qml/views/DashboardView.qml",
        "src/qml/views/ProductsView.qml",
        "src/qml/views/SettingsView.qml",
    ]
    
    missing_files = []
    for file in required_files:
        if not Path(file).exists():
            missing_files.append(file)
        else:
            print(f"  ✓ {file}")
    
    if missing_files:
        print("\nMissing files:")
        for file in missing_files:
            print(f"  ✗ {file}")
        return False
    
    print("✓ All required files present")
    return True

def verify_dependencies():
    """Verify all dependencies are available."""
    print("\nVerifying dependencies...")
    
    try:
        import PySide6
        print("  ✓ PySide6")
        
        import requests
        print("  ✓ requests")
        
        import sqlalchemy
        print("  ✓ SQLAlchemy")
        
        import loguru
        print("  ✓ loguru")
        
        import bcrypt
        print("  ✓ bcrypt")
        
        print("✓ All dependencies available")
        return True
        
    except ImportError as e:
        print(f"  ✗ Missing dependency: {e}")
        return False

def verify_database():
    """Verify database initialization."""
    print("\nVerifying database...")
    
    try:
        # Add src to path
        src_path = Path("src")
        sys.path.insert(0, str(src_path))
        
        from local_db.local_db_manager import LocalDbManager
        from local_db.models import User, Product
        
        db = LocalDbManager()
        print("  ✓ Database connection successful")
        
        # Check if tables exist by trying a simple query
        with db.get_session() as session:
            user_count = session.query(User).count()
            product_count = session.query(Product).count()
            print(f"  ✓ Database contains {user_count} users and {product_count} products")
        
        return True
        
    except Exception as e:
        print(f"  ✗ Database error: {e}")
        return False

def main():
    """Main verification function."""
    print("ChaOffice Application Verification")
    print("=" * 50)
    
    # Run all verification checks
    checks = [
        verify_project_structure(),
        verify_dependencies(),
        verify_database()
    ]
    
    if all(checks):
        print("\n" + "=" * 50)
        print("🎉 ALL VERIFICATIONS PASSED!")
        print("=" * 50)
        print()
        print("Your ChaOffice application is ready to run!")
        print()
        print("To start the application:")
        print("  uv run python run.py")
        print()
        print("Features available:")
        print("  • Hybrid online/offline data management")
        print("  • Modern Qt Quick/QML interface")
        print("  • Dark/light theme support")
        print("  • Product management system")
        print("  • User authentication")
        print("  • Real-time data synchronization")
        print()
        return 0
    else:
        print("\n" + "=" * 50)
        print("❌ SOME VERIFICATIONS FAILED")
        print("=" * 50)
        print("Please check the errors above and fix them before running the application.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
