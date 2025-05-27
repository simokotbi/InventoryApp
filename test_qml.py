#!/usr/bin/env python3
"""
Simple QML loading test for ChaOffice
"""

import sys
import os
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

def test_qml_loading():
    """Test QML loading specifically."""
    
    # Add src to Python path
    src_path = Path(__file__).parent / "src"
    sys.path.insert(0, str(src_path))
    
    print("Testing QML loading...")
    
    try:
        # Create QApplication
        app = QApplication(sys.argv)
        print("✓ QApplication created")
        
        # Create QML engine
        engine = QQmlApplicationEngine()
        print("✓ QML engine created")
        
        # Add import paths
        qml_path = src_path / "qml"
        engine.addImportPath(str(qml_path))
        print(f"✓ Added QML import path: {qml_path}")
        
        # Check main.qml exists
        main_qml = qml_path / "main.qml"
        if not main_qml.exists():
            print(f"✗ main.qml not found: {main_qml}")
            return False
        print(f"✓ main.qml found: {main_qml}")
        
        # Try to load QML
        print("Loading QML...")
        engine.load(QUrl.fromLocalFile(str(main_qml)))
        
        # Check if any root objects were created
        root_objects = engine.rootObjects()
        if not root_objects:
            print("✗ No root objects created - QML loading failed")
            return False
        
        print(f"✓ QML loaded successfully! Created {len(root_objects)} root object(s)")
        
        # Don't run the app event loop, just test loading
        return True
        
    except Exception as e:
        print(f"✗ QML loading failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_qml_loading()
    if success:
        print("\n✓ QML loading test passed!")
        print("The QML application can be loaded successfully.")
    else:
        print("\n✗ QML loading test failed!")
    
    sys.exit(0 if success else 1)
