"""
Application Theme Manager for QML

Manages application theming, colors, fonts, and visual styling.
Provides dynamic theme switching and customization capabilities.
"""
from typing import Dict, Any, Optional
from enum import Enum

from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtGui import QFont, QFontDatabase
from PySide6.QtQml import qmlRegisterType
from loguru import logger

from core.config_manager import ConfigManager


class ThemeMode(Enum):
    LIGHT = "light"
    DARK = "dark"
    AUTO = "auto"


class ThemeManager(QObject):
    """
    QML Theme Manager
    
    Provides centralized theming for the entire application.
    Supports light/dark modes, custom color schemes, and dynamic theme switching.
    """
    
    # Signals for theme changes
    themeChanged = Signal()
    colorsChanged = Signal()
    fontsChanged = Signal()
    
    def __init__(self, config_manager: ConfigManager):
        super().__init__()
        self.config = config_manager
        self._current_theme = "light"
        self._custom_colors = {}
        self._initialize_theme()
    
    def _initialize_theme(self):
        """Initialize theme from configuration"""
        saved_theme = self.config.get_setting("app_theme", "light")
        self._current_theme = saved_theme
        
        # Load custom colors if any
        self._custom_colors = self.config.get_setting("custom_colors", {})
        
        # Load custom fonts
        self._load_custom_fonts()
    
    def _load_custom_fonts(self):
        """Load custom fonts for the application"""
        try:
            # Add custom fonts to the font database
            font_db = QFontDatabase()
            
            # You can add custom font files here
            # font_db.addApplicationFont("path/to/custom/font.ttf")
            
            logger.info("Custom fonts loaded successfully")
            
        except Exception as e:
            logger.error(f"Error loading custom fonts: {e}")
    
    # Theme Mode Properties
    @Property(str, notify=themeChanged)
    def currentTheme(self) -> str:
        return self._current_theme
    
    @Slot(str)
    def setTheme(self, theme: str):
        """Set the current theme"""
        if theme != self._current_theme and theme in ["light", "dark"]:
            self._current_theme = theme
            self.config.update_setting("app_theme", theme)
            self.themeChanged.emit()
            logger.info(f"Theme changed to: {theme}")
    
    # Color Properties for Light Theme
    @Property(str, notify=colorsChanged)
    def primaryColor(self) -> str:
        return self._get_color("primary", "#2196F3")  # Material Blue
    
    @Property(str, notify=colorsChanged)
    def primaryDarkColor(self) -> str:
        return self._get_color("primaryDark", "#1976D2")
    
    @Property(str, notify=colorsChanged)
    def primaryLightColor(self) -> str:
        return self._get_color("primaryLight", "#64B5F6")
    
    @Property(str, notify=colorsChanged)
    def accentColor(self) -> str:
        return self._get_color("accent", "#FF4081")  # Material Pink
    
    @Property(str, notify=colorsChanged)
    def backgroundColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("backgroundDark", "#121212")
        return self._get_color("background", "#FAFAFA")
    
    @Property(str, notify=colorsChanged)
    def surfaceColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("surfaceDark", "#1E1E1E")
        return self._get_color("surface", "#FFFFFF")
    
    @Property(str, notify=colorsChanged)
    def cardColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("cardDark", "#2D2D2D")
        return self._get_color("card", "#FFFFFF")
    
    @Property(str, notify=colorsChanged)
    def textPrimaryColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("textPrimaryDark", "#FFFFFF")
        return self._get_color("textPrimary", "#212121")
    
    @Property(str, notify=colorsChanged)
    def textSecondaryColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("textSecondaryDark", "#B3B3B3")
        return self._get_color("textSecondary", "#757575")
    
    @Property(str, notify=colorsChanged)
    def textHintColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("textHintDark", "#616161")
        return self._get_color("textHint", "#9E9E9E")
    
    @Property(str, notify=colorsChanged)
    def dividerColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("dividerDark", "#3C3C3C")
        return self._get_color("divider", "#E0E0E0")
    
    @Property(str, notify=colorsChanged)
    def borderColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("borderDark", "#404040")
        return self._get_color("border", "#E0E0E0")
    
    # Status Colors
    @Property(str, notify=colorsChanged)
    def successColor(self) -> str:
        return self._get_color("success", "#4CAF50")  # Material Green
    
    @Property(str, notify=colorsChanged)
    def warningColor(self) -> str:
        return self._get_color("warning", "#FF9800")  # Material Orange
    
    @Property(str, notify=colorsChanged)
    def errorColor(self) -> str:
        return self._get_color("error", "#F44336")  # Material Red
    
    @Property(str, notify=colorsChanged)
    def infoColor(self) -> str:
        return self._get_color("info", "#2196F3")  # Material Blue
    
    # Shadow and Elevation
    @Property(str, notify=colorsChanged)
    def shadowColor(self) -> str:
        if self._current_theme == "dark":
            return self._get_color("shadowDark", "#000000")
        return self._get_color("shadow", "#000000")
    
    # Font Properties
    @Property(str, notify=fontsChanged)
    def primaryFont(self) -> str:
        return self._get_font("primary", "Roboto")
    
    @Property(str, notify=fontsChanged)
    def monoFont(self) -> str:
        return self._get_font("mono", "Roboto Mono")
    
    @Property(int, notify=fontsChanged)
    def smallFontSize(self) -> int:
        return 12
    
    @Property(int, notify=fontsChanged)
    def normalFontSize(self) -> int:
        return 14
    
    @Property(int, notify=fontsChanged)
    def mediumFontSize(self) -> int:
        return 16
    
    @Property(int, notify=fontsChanged)
    def largeFontSize(self) -> int:
        return 18
    
    @Property(int, notify=fontsChanged)
    def xlargeFontSize(self) -> int:
        return 24
    
    @Property(int, notify=fontsChanged)
    def xxlargeFontSize(self) -> int:
        return 32
    
    # Spacing and Dimensions
    @Property(int, notify=themeChanged)
    def spacing(self) -> int:
        return 8
    
    @Property(int, notify=themeChanged)
    def spacingSmall(self) -> int:
        return 4
    
    @Property(int, notify=themeChanged)
    def spacingMedium(self) -> int:
        return 16
    
    @Property(int, notify=themeChanged)
    def spacingLarge(self) -> int:
        return 24
    
    @Property(int, notify=themeChanged)
    def spacingXLarge(self) -> int:
        return 32
    
    @Property(int, notify=themeChanged)
    def cornerRadius(self) -> int:
        return 8
    
    @Property(int, notify=themeChanged)
    def cornerRadiusSmall(self) -> int:
        return 4
    
    @Property(int, notify=themeChanged)
    def cornerRadiusLarge(self) -> int:
        return 16
    
    @Property(int, notify=themeChanged)
    def buttonHeight(self) -> int:
        return 40
    
    @Property(int, notify=themeChanged)
    def inputHeight(self) -> int:
        return 48
    
    @Property(int, notify=themeChanged)
    def toolbarHeight(self) -> int:
        return 56
    
    @Property(int, notify=themeChanged)
    def listItemHeight(self) -> int:
        return 48
    
    # Animation Properties
    @Property(int, notify=themeChanged)
    def animationDurationShort(self) -> int:
        return 150
    
    @Property(int, notify=themeChanged)
    def animationDurationMedium(self) -> int:
        return 300
    
    @Property(int, notify=themeChanged)
    def animationDurationLong(self) -> int:
        return 500
    
    # Utility Methods
    def _get_color(self, color_key: str, default: str) -> str:
        """Get color with fallback to default"""
        theme_key = f"{color_key}_{self._current_theme}"
        return self._custom_colors.get(theme_key, self._custom_colors.get(color_key, default))
    
    def _get_font(self, font_key: str, default: str) -> str:
        """Get font with fallback to default"""
        custom_fonts = self.config.get_setting("custom_fonts", {})
        return custom_fonts.get(font_key, default)
    
    @Slot(str, str)
    def setCustomColor(self, color_key: str, color_value: str):
        """Set a custom color"""
        self._custom_colors[color_key] = color_value
        self.config.update_setting("custom_colors", self._custom_colors)
        self.colorsChanged.emit()
        logger.info(f"Custom color set: {color_key} = {color_value}")
    
    @Slot(str, result=str)
    def getColor(self, color_key: str) -> str:
        """Get a color by key"""
        return self._get_color(color_key, "#000000")
    
    @Slot(result='QVariant')
    def getAllColors(self) -> Dict[str, str]:
        """Get all current colors as a dictionary"""
        colors = {
            "primary": self.primaryColor,
            "primaryDark": self.primaryDarkColor,
            "primaryLight": self.primaryLightColor,
            "accent": self.accentColor,
            "background": self.backgroundColor,
            "surface": self.surfaceColor,
            "card": self.cardColor,
            "textPrimary": self.textPrimaryColor,
            "textSecondary": self.textSecondaryColor,
            "textHint": self.textHintColor,
            "divider": self.dividerColor,
            "border": self.borderColor,
            "success": self.successColor,
            "warning": self.warningColor,
            "error": self.errorColor,
            "info": self.infoColor,
            "shadow": self.shadowColor
        }
        return colors
    
    @Slot(result='QVariant')
    def getThemeConfig(self) -> Dict[str, Any]:
        """Get complete theme configuration"""
        return {
            "current_theme": self._current_theme,
            "colors": self.getAllColors(),
            "fonts": {
                "primary": self.primaryFont,
                "mono": self.monoFont
            },
            "dimensions": {
                "spacing": self.spacing,
                "spacingSmall": self.spacingSmall,
                "spacingMedium": self.spacingMedium,
                "spacingLarge": self.spacingLarge,
                "spacingXLarge": self.spacingXLarge,
                "cornerRadius": self.cornerRadius,
                "cornerRadiusSmall": self.cornerRadiusSmall,
                "cornerRadiusLarge": self.cornerRadiusLarge,
                "buttonHeight": self.buttonHeight,
                "inputHeight": self.inputHeight,
                "toolbarHeight": self.toolbarHeight,
                "listItemHeight": self.listItemHeight
            },
            "animations": {
                "durationShort": self.animationDurationShort,
                "durationMedium": self.animationDurationMedium,
                "durationLong": self.animationDurationLong
            }
        }
    
    @Slot()
    def toggleTheme(self):
        """Toggle between light and dark themes"""
        new_theme = "dark" if self._current_theme == "light" else "light"
        self.setTheme(new_theme)
    
    @Slot()
    def resetToDefaults(self):
        """Reset theme to default settings"""
        self._custom_colors = {}
        self.config.update_setting("custom_colors", {})
        self.config.update_setting("custom_fonts", {})
        self.setTheme("light")
        
        self.colorsChanged.emit()
        self.fontsChanged.emit()
        logger.info("Theme reset to defaults")


# Register QML type
def register_theme_types():
    """Register theme-related QML types"""
    qmlRegisterType(ThemeManager, "BusinessApp", 1, 0, "ThemeManager")
