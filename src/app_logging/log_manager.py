"""
Centralized logging configuration using Loguru.
Provides configurable logging with rotation, levels, and custom formatting.
"""

import os
import sys
from pathlib import Path
from typing import Optional, Dict, Any
from loguru import logger


class LogManager:
    """Manages application logging with Loguru."""
    
    def __init__(self):
        self.logger = logger
        self._is_configured = False
        self._default_config = {
            "log_file_path": "logs/chaoffice.log",
            "log_level": "INFO",
            "rotation": "10 MB",
            "retention": "30 days",
            "compression": "zip",
            "format": "{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} | {message}"
        }
    
    def setup_logging(self, config: Optional[Dict[str, Any]] = None) -> None:
        """Set up logging configuration."""
        if self._is_configured:
            return
        
        # Use provided config or default
        log_config = config or self._default_config
        
        # Remove default logger
        self.logger.remove()
        
        # Add console logger
        self.logger.add(
            sys.stderr,
            level=log_config.get("log_level", "INFO"),
            format=log_config.get("format"),
            colorize=True
        )
        
        # Ensure log directory exists
        log_file_path = log_config.get("log_file_path", self._default_config["log_file_path"])
        log_dir = Path(log_file_path).parent
        log_dir.mkdir(parents=True, exist_ok=True)
        
        # Add file logger with rotation
        self.logger.add(
            log_file_path,
            level=log_config.get("log_level", "INFO"),
            format=log_config.get("format"),
            rotation=log_config.get("rotation", "10 MB"),
            retention=log_config.get("retention", "30 days"),
            compression=log_config.get("compression", "zip"),
            enqueue=True  # Thread-safe logging
        )
        
        self._is_configured = True
        self.logger.info("Logging system initialized")
    
    def update_log_level(self, level: str) -> None:
        """Update the logging level dynamically."""
        try:
            # Remove existing handlers and re-add with new level
            self.logger.remove()
            self.setup_logging({
                **self._default_config,
                "log_level": level.upper()
            })
            self.logger.info(f"Log level updated to {level.upper()}")
        except Exception as e:
            self.logger.error(f"Failed to update log level: {e}")
    
    def update_log_file_path(self, file_path: str) -> None:
        """Update the log file path dynamically."""
        try:
            # Remove existing handlers and re-add with new path
            self.logger.remove()
            self.setup_logging({
                **self._default_config,
                "log_file_path": file_path
            })
            self.logger.info(f"Log file path updated to {file_path}")
        except Exception as e:
            self.logger.error(f"Failed to update log file path: {e}")
    
    def get_log_levels(self) -> list[str]:
        """Get available log levels."""
        return ["TRACE", "DEBUG", "INFO", "SUCCESS", "WARNING", "ERROR", "CRITICAL"]
    
    def get_current_config(self) -> Dict[str, Any]:
        """Get current logging configuration."""
        return self._default_config.copy()
    
    def cleanup(self) -> None:
        """Clean up logging resources."""
        self.logger.remove()
        self._is_configured = False
