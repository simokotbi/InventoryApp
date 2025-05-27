"""
Navigation manager for QML view management.
"""

from typing import Optional
from PySide6.QtCore import QObject, Signal, Slot, Property
from app_logger.log_manager import LogManager


class NavigationManager(QObject):
    """Manages QML view navigation and application state."""
    
    # Signals
    currentViewChanged = Signal(str)
    navigationRequested = Signal(str)
    
    def __init__(self, parent=None):
        """Initialize navigation manager."""
        super().__init__(parent)
        self.logger = LogManager().get_logger("NavigationManager")
        self._current_view = "dashboard"
        
    @Property(str, notify=currentViewChanged)
    def currentView(self) -> str:
        """Get current view name."""
        return self._current_view
    
    @Slot(str)
    def navigateTo(self, view_name: str) -> None:
        """Navigate to a specific view."""
        if view_name != self._current_view:
            self.logger.info(f"Navigating from {self._current_view} to {view_name}")
            self._current_view = view_name
            self.currentViewChanged.emit(view_name)
            self.navigationRequested.emit(view_name)
    
    @Slot()
    def goBack(self) -> None:
        """Go back to previous view (placeholder for future implementation)."""
        self.logger.info("Back navigation requested")
        # For now, go to dashboard
        self.navigateTo("dashboard")
