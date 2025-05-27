#!/usr/bin/env python3
"""
Quick QML syntax validation script.
"""
import sys
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

def validate_qml():
    """Validate main QML file syntax."""
    try:
        app = QApplication(sys.argv)
        engine = QQmlApplicationEngine()
        
        # Add import paths
        src_path = Path(__file__).parent / "src"
        qml_path = src_path / "qml"
        engine.addImportPath(str(qml_path))
        
        # Load main QML
        main_qml = qml_path / "main.qml"
        print(f"Loading QML from: {main_qml}")
        
        if not main_qml.exists():
            print(f"ERROR: QML file not found: {main_qml}")
            return False
        
        # Connect to warnings to catch QML errors
        def handle_warnings(warnings):
            for warning in warnings:
                print(f"QML Warning: {warning}")
        
        engine.warnings.connect(lambda warnings: [print(f"QML Warning: {w.toString()}") for w in warnings])
        
        engine.load(QUrl.fromLocalFile(str(main_qml)))
        
        if not engine.rootObjects():
            print("ERROR: Failed to load QML - no root objects created")
            return False
        
        print("SUCCESS: QML loaded successfully")
        return True
        
    except Exception as e:
        print(f"Exception during QML validation: {e}")
        return False

if __name__ == "__main__":
    success = validate_qml()
    sys.exit(0 if success else 1)
