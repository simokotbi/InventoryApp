#!/usr/bin/env python3
"""
ChaoOffice startup script
"""

import sys
import os
from pathlib import Path

# Add src directory to Python path
project_root = Path(__file__).parent
src_path = project_root / "src"
sys.path.insert(0, str(src_path))

# Import and run the main application
from main import main

if __name__ == "__main__":
    main()
