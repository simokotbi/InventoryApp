"""
Configuration manager for ChaOffice application.
Handles application settings, online/offline mode, and Supabase configuration.
"""

import json
from pathlib import Path
from typing import Dict, Any, Optional
from dataclasses import dataclass
from app_logger.log_manager import LogManager


@dataclass
class SupabaseConfig:
    """Supabase configuration data."""
    url: str
    anon_key: str


@dataclass
class AppConfig:
    """Application configuration data."""
    is_online: bool
    theme: str
    log_level: str
    database_file: str
    supabase: SupabaseConfig


class ConfigManager:
    """Manages application configuration and settings."""
    
    def __init__(self, config_file: Optional[Path] = None):
        """Initialize configuration manager."""
        self.logger = LogManager().get_logger("ConfigManager")
        self.config_file = config_file or Path("instance_settings.json")
        self._config: Optional[AppConfig] = None
        self._load_config()
        
    def _load_config(self) -> None:
        """Load configuration from file."""
        try:
            if not self.config_file.exists():
                self.logger.warning(f"Config file {self.config_file} not found, creating default")
                self._create_default_config()
                return
                
            with open(self.config_file, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
                
            # Validate and create config object
            supabase_config = SupabaseConfig(
                url=config_data.get("supabase_url", ""),
                anon_key=config_data.get("supabase_anon_key", "")
            )
            
            self._config = AppConfig(
                is_online=config_data.get("is_online", False),
                theme=config_data.get("theme", "light"),
                log_level=config_data.get("log_level", "INFO"),
                database_file=config_data.get("database_file", "instance/chaoffice.db"),
                supabase=supabase_config
            )
            
            self.logger.info(f"Configuration loaded from {self.config_file}")
            
        except Exception as e:
            self.logger.error(f"Failed to load configuration: {e}")
            self._create_default_config()
    
    def _create_default_config(self) -> None:
        """Create default configuration."""
        default_config = {
            "supabase_url": "your-supabase-project-url-here",
            "supabase_anon_key": "your-supabase-anon-key-here",
            "is_online": False,
            "theme": "light",
            "log_level": "INFO",
            "database_file": "instance/chaoffice.db"
        }
        
        try:
            # Ensure directory exists
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=4)
                
            self.logger.info(f"Default configuration created at {self.config_file}")
            self._load_config()
            
        except Exception as e:
            self.logger.error(f"Failed to create default configuration: {e}")
            # Create minimal in-memory config
            supabase_config = SupabaseConfig(url="", anon_key="")
            self._config = AppConfig(
                is_online=False,
                theme="light",
                log_level="INFO",
                database_file="instance/chaoffice.db",
                supabase=supabase_config
            )
    
    def save_config(self) -> bool:
        """Save current configuration to file."""
        try:
            if not self._config:
                self.logger.error("No configuration to save")
                return False
                
            config_data = {
                "supabase_url": self._config.supabase.url,
                "supabase_anon_key": self._config.supabase.anon_key,
                "is_online": self._config.is_online,
                "theme": self._config.theme,
                "log_level": self._config.log_level,
                "database_file": self._config.database_file
            }
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config_data, f, indent=4)
                
            self.logger.info("Configuration saved successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to save configuration: {e}")
            return False
    
    @property
    def is_online(self) -> bool:
        """Get online mode status."""
        return self._config.is_online if self._config else False
    
    @is_online.setter
    def is_online(self, value: bool) -> None:
        """Set online mode status."""
        if self._config:
            self._config.is_online = value
            self.save_config()
            self.logger.info(f"Online mode set to: {value}")
    
    @property
    def theme(self) -> str:
        """Get current theme."""
        return self._config.theme if self._config else "light"
    
    @theme.setter
    def theme(self, value: str) -> None:
        """Set theme."""
        if self._config and value in ["light", "dark"]:
            self._config.theme = value
            self.save_config()
            self.logger.info(f"Theme set to: {value}")
    
    @property
    def database_file(self) -> str:
        """Get database file path."""
        return self._config.database_file if self._config else "instance/chaoffice.db"
    
    @property
    def supabase_url(self) -> str:
        """Get Supabase URL."""
        return self._config.supabase.url if self._config else ""
    
    @property
    def supabase_anon_key(self) -> str:
        """Get Supabase anonymous key."""
        return self._config.supabase.anon_key if self._config else ""
    
    def toggle_online_mode(self) -> bool:
        """Toggle online/offline mode."""
        new_mode = not self.is_online
        self.is_online = new_mode
        return new_mode
    
    def toggle_theme(self) -> str:
        """Toggle between light and dark theme."""
        new_theme = "dark" if self.theme == "light" else "light"
        self.theme = new_theme
        return new_theme
    
    def has_valid_supabase_config(self) -> bool:
        """Check if Supabase configuration is valid."""
        return (
            self._config and 
            self._config.supabase.url and 
            self._config.supabase.anon_key and
            not self._config.supabase.url.startswith("your-") and
            not self._config.supabase.anon_key.startswith("your-")
        )
