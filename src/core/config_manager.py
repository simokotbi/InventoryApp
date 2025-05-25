"""
Configuration manager for application settings.
Handles Supabase configuration, theme settings, and application state.
"""

import json
import os
from pathlib import Path
from typing import Dict, Any, Optional
from PySide6.QtCore import QObject, Signal, Property, Slot


class ConfigManager(QObject):
    """Manages application configuration and settings."""
    
    # Signals for QML property changes
    isOnlineChanged = Signal()
    isDarkModeChanged = Signal()
    primaryColorChanged = Signal()
    accentColorChanged = Signal()
    
    def __init__(self):
        super().__init__()
        self._config_file_path = "instance_settings.json"
        self._config = self._get_default_config()
        self._is_loaded = False
    
    def _get_default_config(self) -> Dict[str, Any]:
        """Get default configuration."""
        return {
            # Application mode
            "is_online": False,
            "environment": "development",  # development, production
            
            # Supabase configuration
            "supabase": {
                "url": "",
                "anon_key": "",
                "service_role_key": ""
            },
            
            # Database configuration
            "database": {
                "local_db_path": "data/chaoffice.db"
            },
            
            # Theme configuration
            "theme": {
                "is_dark_mode": False,
                "primary_color": "#2196F3",
                "accent_color": "#FF5722",
                "background_color_light": "#FFFFFF",
                "background_color_dark": "#121212",
                "surface_color_light": "#F5F5F5",
                "surface_color_dark": "#1E1E1E",
                "text_color_light": "#212121",
                "text_color_dark": "#FFFFFF"
            },
            
            # Logging configuration
            "logging": {
                "log_file_path": "logs/chaoffice.log",
                "log_level": "INFO",
                "rotation": "10 MB",
                "retention": "30 days"
            },
            
            # User preferences
            "user": {
                "remember_login": True,
                "auto_sync": True,
                "sync_interval_minutes": 5
            }
        }
    
    def load_config(self) -> None:
        """Load configuration from file."""
        try:
            if os.path.exists(self._config_file_path):
                with open(self._config_file_path, 'r') as f:
                    loaded_config = json.load(f)
                
                # Merge with defaults to ensure all keys exist
                self._merge_config(self._config, loaded_config)
            
            # Ensure data directory exists
            data_dir = Path(self.get_database_path()).parent
            data_dir.mkdir(parents=True, exist_ok=True)
            
            self._is_loaded = True
            
        except Exception as e:
            print(f"Failed to load config: {e}")
            # Use defaults if loading fails
    
    def _merge_config(self, default: Dict[str, Any], loaded: Dict[str, Any]) -> None:
        """Recursively merge loaded config with defaults."""
        for key, value in loaded.items():
            if key in default:
                if isinstance(value, dict) and isinstance(default[key], dict):
                    self._merge_config(default[key], value)
                else:
                    default[key] = value
    
    def save_config(self) -> None:
        """Save current configuration to file."""
        try:
            # Ensure directory exists
            config_dir = Path(self._config_file_path).parent
            config_dir.mkdir(parents=True, exist_ok=True)
            
            with open(self._config_file_path, 'w') as f:
                json.dump(self._config, f, indent=2)
        except Exception as e:
            print(f"Failed to save config: {e}")
    
    # Properties for QML access
    @Property(bool, notify=isOnlineChanged)
    def is_online(self) -> bool:
        """Check if application is in online mode."""
        return self._config["is_online"]
    
    @is_online.setter
    def is_online(self, value: bool) -> None:
        """Set online mode."""
        if self._config["is_online"] != value:
            self._config["is_online"] = value
            self.isOnlineChanged.emit()
            self.save_config()
    
    @Property(bool, notify=isDarkModeChanged)
    def is_dark_mode(self) -> bool:
        """Check if dark mode is enabled."""
        return self._config["theme"]["is_dark_mode"]
    
    @is_dark_mode.setter
    def is_dark_mode(self, value: bool) -> None:
        """Set dark mode."""
        if self._config["theme"]["is_dark_mode"] != value:
            self._config["theme"]["is_dark_mode"] = value
            self.isDarkModeChanged.emit()
            self.save_config()
    
    @Property(str, notify=primaryColorChanged)
    def primary_color(self) -> str:
        """Get primary color."""
        return self._config["theme"]["primary_color"]
    
    @primary_color.setter
    def primary_color(self, value: str) -> None:
        """Set primary color."""
        if self._config["theme"]["primary_color"] != value:
            self._config["theme"]["primary_color"] = value
            self.primaryColorChanged.emit()
            self.save_config()
    
    @Property(str, notify=accentColorChanged)
    def accent_color(self) -> str:
        """Get accent color."""
        return self._config["theme"]["accent_color"]
    
    @accent_color.setter
    def accent_color(self, value: str) -> None:
        """Set accent color."""
        if self._config["theme"]["accent_color"] != value:
            self._config["theme"]["accent_color"] = value
            self.accentColorChanged.emit()
            self.save_config()
    
    # Theme color getters for QML
    @Property(str, constant=True)
    def background_color(self) -> str:
        """Get background color based on theme."""
        if self.is_dark_mode:
            return self._config["theme"]["background_color_dark"]
        return self._config["theme"]["background_color_light"]
    
    @Property(str, constant=True)
    def surface_color(self) -> str:
        """Get surface color based on theme."""
        if self.is_dark_mode:
            return self._config["theme"]["surface_color_dark"]
        return self._config["theme"]["surface_color_light"]
    
    @Property(str, constant=True)
    def text_color(self) -> str:
        """Get text color based on theme."""
        if self.is_dark_mode:
            return self._config["theme"]["text_color_dark"]
        return self._config["theme"]["text_color_light"]
    
    # Slots for QML interaction
    @Slot()
    def toggle_dark_mode(self) -> None:
        """Toggle dark mode."""
        self.is_dark_mode = not self.is_dark_mode
    
    @Slot()
    def toggle_online_mode(self) -> None:
        """Toggle online mode."""
        self.is_online = not self.is_online
    
    @Slot(str)
    def update_primary_color(self, color: str) -> None:
        """Update primary color from QML."""
        self.primary_color = color
    
    @Slot(str)
    def update_accent_color(self, color: str) -> None:
        """Update accent color from QML."""
        self.accent_color = color
    
    # Configuration getters
    def get_supabase_config(self) -> Dict[str, str]:
        """Get Supabase configuration."""
        return self._config["supabase"].copy()
    
    def get_database_path(self) -> str:
        """Get local database path."""
        return self._config["database"]["local_db_path"]
    
    def get_logging_config(self) -> Dict[str, Any]:
        """Get logging configuration."""
        return self._config["logging"].copy()
    
    def get_user_preferences(self) -> Dict[str, Any]:
        """Get user preferences."""
        return self._config["user"].copy()
    
    def is_development_mode(self) -> bool:
        """Check if in development mode."""
        return self._config["environment"] == "development"
    
    # Configuration setters
    def set_supabase_config(self, url: str, anon_key: str, service_role_key: str = "") -> None:
        """Set Supabase configuration."""
        self._config["supabase"]["url"] = url
        self._config["supabase"]["anon_key"] = anon_key
        self._config["supabase"]["service_role_key"] = service_role_key
        self.save_config()
    
    def update_logging_config(self, config: Dict[str, Any]) -> None:
        """Update logging configuration."""
        self._config["logging"].update(config)
        self.save_config()
    
    def update_user_preferences(self, preferences: Dict[str, Any]) -> None:
        """Update user preferences."""
        self._config["user"].update(preferences)
        self.save_config()
    
    def get_setting(self, key: str, default: Any = None) -> Any:
        """Get a configuration setting with optional default value."""
        # First try user preferences
        if key in self._config["user"]:
            return self._config["user"][key]
        
        # Then try theme settings
        if key in self._config["theme"]:
            return self._config["theme"][key]
        
        # Finally try top-level config
        if key in self._config:
            return self._config[key]
            
        return default
    
    def set_setting(self, key: str, value: Any) -> None:
        """Set a configuration setting in user preferences."""
        self._config["user"][key] = value
        self.save_config()
    
    def update_setting(self, key: str, value: Any) -> None:
        """Update a configuration setting (alias for set_setting)."""
        self.set_setting(key, value)
