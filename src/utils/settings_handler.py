from PySide6.QtCore import QObject, Signal, Slot, Property
from .config_manager import ConfigManager
from .logger import get_logger

logger = get_logger()

class SettingsHandler(QObject):
    settingsChanged = Signal()
    themeChanged = Signal()

    def __init__(self):
        super().__init__()
        self.config = ConfigManager()
        self._load_settings()

    def _load_settings(self):
        """Load settings from config file"""
        self._dark_mode_value = self.config.get('theme.dark_mode', False)
        self._primary_color_value = self.config.get('theme.primary_color', '#3498DB')
        self._font_family_value = self.config.get('theme.font_family', 'Segoe UI')
        self._auto_logout_value = self.config.get('auth.auto_logout_minutes', 30)
        self._session_timeout_value = self.config.get('auth.token_expiry_hours', 24)

    def _get_dark_mode(self) -> bool:
        return self._dark_mode_value

    def _set_dark_mode(self, value: bool):
        if self._dark_mode_value != value:
            self._dark_mode_value = value
            self.config.set('theme.dark_mode', value)
            self.themeChanged.emit()

    def _get_primary_color(self) -> str:
        return self._primary_color_value

    def _set_primary_color(self, value: str):
        if self._primary_color_value != value:
            self._primary_color_value = value
            self.config.set('theme.primary_color', value)
            self.themeChanged.emit()

    def _get_font_family(self) -> str:
        return self._font_family_value

    def _set_font_family(self, value: str):
        if self._font_family_value != value:
            self._font_family_value = value
            self.config.set('theme.font_family', value)
            self.themeChanged.emit()

    def _get_auto_logout(self) -> int:
        return self._auto_logout_value

    def _set_auto_logout(self, value: int):
        if self._auto_logout_value != value:
            self._auto_logout_value = value
            self.config.set('auth.auto_logout_minutes', value)
            self.settingsChanged.emit()

    def _get_session_timeout(self) -> int:
        return self._session_timeout_value

    def _set_session_timeout(self, value: int):
        if self._session_timeout_value != value:
            self._session_timeout_value = value
            self.config.set('auth.token_expiry_hours', value)
            self.settingsChanged.emit()

    darkMode = Property(bool, _get_dark_mode, _set_dark_mode, notify=themeChanged)
    primaryColor = Property(str, _get_primary_color, _set_primary_color, notify=themeChanged)
    fontFamily = Property(str, _get_font_family, _set_font_family, notify=themeChanged)
    autoLogout = Property(int, _get_auto_logout, _set_auto_logout, notify=settingsChanged)
    sessionTimeout = Property(int, _get_session_timeout, _set_session_timeout, notify=settingsChanged)

    @Slot()
    def restoreDefaults(self):
        """Restore settings to default values"""
        self.config.reset()
        self._load_settings()
        self.themeChanged.emit()
        self.settingsChanged.emit()
        logger.info("Settings restored to defaults")
        return True

    COLOR_MAP = {
        "Blue": "#3498DB",
        "Green": "#2ECC71",
        "Purple": "#9B59B6",
        "Orange": "#E67E22"
    }

    @Slot(str, result=bool)
    def setPrimaryColorByName(self, colorName: str):
        """Set primary color using a predefined color name"""
        if colorName in self.COLOR_MAP:
            self.primaryColor = self.COLOR_MAP[colorName]
            logger.info(f"Primary color set to {colorName}")
            return True
        logger.warning(f"Invalid color name: {colorName}")
        return False

    @Slot(result=str)
    def getCurrentColorName(self):
        """Get the current color name based on the hex value"""
        for name, color in self.COLOR_MAP.items():
            if color.lower() == self._primary_color_value.lower():
                return name
        return "Blue"  # Default