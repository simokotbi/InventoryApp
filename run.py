#!/usr/bin/env python3
"""Simple script to run the ChaOffice application."""

import subprocess
import sys
from pathlib import Path

def main():
    """Run the application using uv."""
    try:
        # Change to project root
        project_root = Path(__file__).parent
        
        # Run with uv
        result = subprocess.run([
            "uv", "run", "python", "src/main.py"
        ], cwd=project_root)
        
        return result.returncode
        
    except FileNotFoundError:
        print("Error: 'uv' not found. Please install uv first.")
        print("Visit: https://github.com/astral-sh/uv")
        return 1
    except Exception as e:
        print(f"Error running application: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
