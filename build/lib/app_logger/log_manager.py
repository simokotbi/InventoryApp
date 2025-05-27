"""
Centralized Loguru-based logging configuration for ChaOffice.
"""

import sys
from pathlib import Path
from typing import Optional
from loguru import logger


class LogManager:
    """Manages application logging using Loguru."""
    
    _instance: Optional['LogManager'] = None
    _initialized: bool = False
    
    def __new__(cls) -> 'LogManager':
        """Singleton pattern implementation."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize logging configuration."""
        if not self._initialized:
            self._setup_logging()
            LogManager._initialized = True
    
    def _setup_logging(self) -> None:
        """Configure Loguru logging."""
        # Remove default handler
        logger.remove()
        
        # Console handler with colored output
        logger.add(
            sys.stderr,
            format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
                   "<level>{level: <8}</level> | "
                   "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
                   "<level>{message}</level>",
            level="INFO",
            colorize=True
        )
        
        # File handler for all logs
        log_dir = Path("logs")
        log_dir.mkdir(exist_ok=True)
        
        logger.add(
            log_dir / "chaoffice.log",
            format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
            level="DEBUG",
            rotation="10 MB",
            retention="30 days",
            compression="zip"
        )
        
        # Error file handler
        logger.add(
            log_dir / "chaoffice_errors.log",
            format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
            level="ERROR",
            rotation="5 MB",
            retention="90 days",
            compression="zip"
        )
        
        logger.info("Logging system initialized")
    
    def get_logger(self, name: str = "ChaOffice"):
        """Get a logger with the specified name."""
        return logger.bind(name=name)
    
    def set_level(self, level: str) -> None:
        """Set the logging level."""
        # Note: Loguru doesn't allow runtime level changes easily
        # This is a placeholder for future implementation
        logger.info(f"Log level change requested: {level}")
        
    @classmethod
    def shutdown(cls) -> None:
        """Shutdown logging system."""
        logger.remove()
        logger.info("Logging system shutdown")
