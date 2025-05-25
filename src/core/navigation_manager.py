"""
Navigation manager for QML view transitions and application state.
"""

from typing import Optional, Dict, Any
from PySide6.QtCore import QObject, Signal, Property, Slot


class NavigationManager(QObject):
    """Manages navigation between different views in the application."""
    
    # Signals
    currentViewChanged = Signal()
    navigationRequested = Signal(str, 'QVariant')  # view_name, parameters
    authenticationChanged = Signal(bool)  # is_authenticated
    
    def __init__(self):
        super().__init__()
        self._current_view = "signin"
        self._view_history: list[str] = []
        self._is_authenticated = False
        self._user_role = ""
        
        # Define available views and their access requirements
        self._views = {
            "signin": {"auth_required": False, "roles": []},
            "signup": {"auth_required": False, "roles": []},
            "dashboard": {"auth_required": True, "roles": ["admin", "sales", "inventory"]},
            "products": {"auth_required": True, "roles": ["admin", "inventory"]},
            "customers": {"auth_required": True, "roles": ["admin", "sales"]},
            "sales": {"auth_required": True, "roles": ["admin", "sales"]},
            "inventory": {"auth_required": True, "roles": ["admin", "inventory"]},
            "reports": {"auth_required": True, "roles": ["admin"]},
            "user_settings": {"auth_required": True, "roles": ["admin", "sales", "inventory"]},
            "general_settings": {"auth_required": True, "roles": ["admin"]},
            "unauthorized": {"auth_required": False, "roles": []}
        }
    
    @Property(str, notify=currentViewChanged)
    def current_view(self) -> str:
        """Get the current view name."""
        return self._current_view
    
    @Property(bool, notify=authenticationChanged)
    def is_authenticated(self) -> bool:
        """Check if user is authenticated."""
        return self._is_authenticated
    
    @Property(str, constant=True)
    def user_role(self) -> str:
        """Get the current user role."""
        return self._user_role
    
    @Slot(str)
    @Slot(str, 'QVariant')
    def navigate_to(self, view_name: str, parameters: Optional[Dict[str, Any]] = None) -> None:
        """Navigate to a specific view."""
        if not self._can_access_view(view_name):
            # Redirect to unauthorized page if access denied
            view_name = "unauthorized"
        
        if view_name != self._current_view:
            # Add current view to history if it's not already there
            if self._current_view not in self._view_history:
                self._view_history.append(self._current_view)
            
            # Limit history size
            if len(self._view_history) > 10:
                self._view_history.pop(0)
            
            self._current_view = view_name
            self.currentViewChanged.emit()
            self.navigationRequested.emit(view_name, parameters or {})
    
    @Slot()
    def go_back(self) -> None:
        """Navigate back to the previous view."""
        if self._view_history:
            previous_view = self._view_history.pop()
            if self._can_access_view(previous_view):
                self._current_view = previous_view
                self.currentViewChanged.emit()
                self.navigationRequested.emit(previous_view, {})
            else:
                # Try the next item in history
                self.go_back()
    
    @Slot()
    def clear_history(self) -> None:
        """Clear navigation history."""
        self._view_history.clear()
    
    @Slot(bool, str)
    def set_authentication_state(self, is_authenticated: bool, user_role: str = "") -> None:
        """Set the authentication state."""
        if self._is_authenticated != is_authenticated:
            self._is_authenticated = is_authenticated
            self._user_role = user_role
            self.authenticationChanged.emit(is_authenticated)
            
            # Navigate to appropriate view based on auth state
            if is_authenticated:
                self.navigate_to("dashboard")
            else:
                self.navigate_to("signin")
                self.clear_history()
    
    @Slot()
    def logout(self) -> None:
        """Handle user logout."""
        self.set_authentication_state(False, "")
    
    def _can_access_view(self, view_name: str) -> bool:
        """Check if the current user can access the specified view."""
        if view_name not in self._views:
            return False
        
        view_config = self._views[view_name]
        
        # Check authentication requirement
        if view_config["auth_required"] and not self._is_authenticated:
            return False
        
        # Check role requirement
        if view_config["roles"] and self._user_role not in view_config["roles"]:
            return False
        
        return True
    
    @Slot(str, result=bool)
    def can_access_view(self, view_name: str) -> bool:
        """QML-accessible method to check view access."""
        return self._can_access_view(view_name)
    
    @Slot(result='QStringList')
    def get_accessible_views(self) -> list[str]:
        """Get list of views accessible to current user."""
        accessible = []
        for view_name in self._views.keys():
            if self._can_access_view(view_name):
                accessible.append(view_name)
        return accessible
    
    @Slot(result='QStringList')
    def get_navigation_items(self) -> list[str]:
        """Get navigation menu items for current user."""
        navigation_items = []
        
        if self._is_authenticated:
            # Always show dashboard
            navigation_items.append("dashboard")
            
            # Add role-based items
            if self._user_role in ["admin", "inventory"]:
                navigation_items.append("products")
            
            if self._user_role in ["admin", "sales"]:
                navigation_items.append("customers")
                navigation_items.append("sales")
            
            if self._user_role in ["admin", "inventory"]:
                navigation_items.append("inventory")
            
            if self._user_role == "admin":
                navigation_items.append("reports")
                navigation_items.append("general_settings")
            
            # Always show user settings for authenticated users
            navigation_items.append("user_settings")
        
        return navigation_items
    
    @Slot(str, result=str)
    def get_view_title(self, view_name: str) -> str:
        """Get display title for a view."""
        titles = {
            "signin": "Sign In",
            "signup": "Sign Up",
            "dashboard": "Dashboard",
            "products": "Product Management",
            "customers": "Customer Management",
            "sales": "Sales Management",
            "inventory": "Inventory",
            "reports": "Reports",
            "user_settings": "User Settings",
            "general_settings": "General Settings",
            "unauthorized": "Access Denied"
        }
        return titles.get(view_name, view_name.title())
    
    @Slot(str, result=str)
    def get_view_icon(self, view_name: str) -> str:
        """Get icon name for a view."""
        icons = {
            "signin": "login",
            "signup": "person_add",
            "dashboard": "dashboard",
            "products": "inventory_2",
            "customers": "people",
            "sales": "point_of_sale",
            "inventory": "warehouse",
            "reports": "analytics",
            "user_settings": "account_circle",
            "general_settings": "settings",
            "unauthorized": "block"
        }
        return icons.get(view_name, "page")
