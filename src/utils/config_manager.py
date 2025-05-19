import json
import os
from pathlib import Path
from typing import Any, Dict, Optional

class ConfigManager:
    """Manages application configuration settings"""
    
    def __init__(self, config_file: str = "config.json"):
        self.config_dir = Path.home() / ".qt_auth_app"
        self.config_file = self.config_dir / config_file
        self.config: Dict[str, Any] = {}
        self._ensure_config_dir()
        self.load_config()

    def _ensure_config_dir(self) -> None:
        """Ensure the configuration directory exists"""
        self.config_dir.mkdir(parents=True, exist_ok=True)

    def load_config(self) -> None:
        """Load configuration from file"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    self.config = json.load(f)
            except json.JSONDecodeError:
                self.config = {}
        else:
            self.config = self._default_config()
            self.save_config()

    def save_config(self) -> None:
        """Save current configuration to file"""
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=4)

    def _default_config(self) -> Dict[str, Any]:
        """Return default configuration settings"""
        return {
            "theme": {
                "dark_mode": False,
                "primary_color": "#3498DB",
                "secondary_color": "#2ECC71",
                "font_family": "Segoe UI"
            },
            "database": {
                "path": str(Path(__file__).parent.parent.parent / "app_database.db")
            },
            "auth": {
                "token_expiry_hours": 24,
                "min_password_length": 8
            }
        }

    def get(self, key: str, default: Any = None) -> Any:
        """
        Get a configuration value by key.
        
        Args:
            key: The configuration key (can be nested using dots, e.g., 'theme.dark_mode')
            default: Default value if key doesn't exist
            
        Returns:
            The configuration value or default
        """
        try:
            value = self.config
            for k in key.split('.'):
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default

    def set(self, key: str, value: Any) -> None:
        """
        Set a configuration value.
        
        Args:
            key: The configuration key (can be nested using dots)
            value: The value to set
        """
        keys = key.split('.')
        current = self.config
        
        # Navigate to the correct nested level
        for k in keys[:-1]:
            if k not in current:
                current[k] = {}
            current = current[k]
        
        # Set the value
        current[keys[-1]] = value
        self.save_config()

    def reset(self) -> None:
        """Reset configuration to defaults"""
        self.config = self._default_config()
        self.save_config()