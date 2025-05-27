#!/usr/bin/env python3
"""
ChaOffice Quick Launcher
Simple script to launch the ChaOffice application with proper setup
"""

import sys
import subprocess
from pathlib import Path

def main():
    """Launch the ChaOffice application."""
    print("🚀 ChaOffice Quick Launcher")
    print("=" * 40)
    
    # Check if we're in the right directory
    if not Path("pyproject.toml").exists():
        print("❌ Error: Please run this script from the ChaOffice project root directory")
        return 1
    
    # Check if uv is available
    try:
        subprocess.run(["uv", "--version"], capture_output=True, check=True)
        print("✅ UV package manager found")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Error: UV package manager not found")
        print("   Please install UV: https://github.com/astral-sh/uv")
        return 1
    
    print("🔧 Setting up environment...")
    
    # Install dependencies if needed
    try:
        subprocess.run(["uv", "sync"], check=True, capture_output=True)
        print("✅ Dependencies synchronized")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error installing dependencies: {e}")
        return 1
    
    # Initialize database if needed
    print("🗄️  Initializing database...")
    try:
        subprocess.run(["uv", "run", "python", "-m", "src.local_db.init_local_db"], 
                      check=True, capture_output=True)
        print("✅ Database initialized")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error initializing database: {e}")
        return 1
    
    print("🎨 Starting ChaOffice application...")
    print("   (Close the application window to return to terminal)")
    print()
    
    # Launch the application
    try:
        result = subprocess.run(["uv", "run", "python", "run.py"])
        print("\n👋 ChaOffice application closed")
        return result.returncode
    except KeyboardInterrupt:
        print("\n⚡ Application interrupted by user")
        return 0
    except Exception as e:
        print(f"\n❌ Error running application: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
