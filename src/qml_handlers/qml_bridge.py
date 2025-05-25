"""
QML Bridge Handlers

Python handlers that bridge QML frontend with business logic services.
These handlers are exposed to QML as context properties and provide
the interface between the UI and backend systems.
"""
from typing import Dict, Any, List, Optional
from datetime import datetime, timezone
from decimal import Decimal

from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from PySide6.QtQml import qmlRegisterType
from loguru import logger

from services.business_services import (
    UserService, ProductService, CustomerService, 
    SalesService, InventoryService, ReportService
)
from services.auth_service import AuthService
from api_client.sync_manager import SyncManager


class AuthHandler(QObject):
    """QML handler for authentication operations"""
    
    # Signals for QML
    loginResult = Signal(bool, str, 'QVariant')  # success, message, user_data
    logoutResult = Signal(bool, str)  # success, message
    permissionChanged = Signal()
    userChanged = Signal()
    
    def __init__(self, auth_service: AuthService):
        super().__init__()
        self.auth_service = auth_service
        self._current_user = None
        self._is_authenticated = False
        self._permissions = {}
    
    @Property(bool, notify=userChanged)
    def isAuthenticated(self) -> bool:
        return self._is_authenticated
    
    @Property('QVariant', notify=userChanged)
    def currentUser(self):
        return self._current_user
    
    @Property('QVariant', notify=permissionChanged)
    def permissions(self):
        return self._permissions
    
    @Slot(str, str, bool, result='QVariant')
    def login(self, username: str, password: str, remember_me: bool = False) -> Dict[str, Any]:
        """
        Authenticate user and return result.
        
        Args:
            username: Username or email
            password: Password
            remember_me: Whether to remember login
            
        Returns:
            Dict with login result
        """
        try:
            # Note: In a real implementation, you'd use asyncio.run() or proper async handling
            # For this example, we'll simulate the async call
            logger.info(f"Login attempt for: {username}")
            
            # This would be an async call in practice
            result = self.auth_service.login(username, password, remember_me)
            
            if result.success:
                session = result.data.get('session', {})
                user_data = result.data.get('user', {})
                
                self._current_user = user_data
                self._is_authenticated = True
                self._permissions = session.get('permissions', {})
                
                self.userChanged.emit()
                self.permissionChanged.emit()
                self.loginResult.emit(True, result.message, user_data)
                
                logger.info(f"Login successful for: {username}")
                
                return {
                    "success": True,
                    "message": result.message,
                    "user": user_data
                }
            else:
                self.loginResult.emit(False, result.errors[0] if result.errors else "Login failed", {})
                
                return {
                    "success": False,
                    "message": result.errors[0] if result.errors else "Login failed"
                }
                
        except Exception as e:
            error_msg = f"Login error: {str(e)}"
            logger.error(error_msg)
            self.loginResult.emit(False, error_msg, {})
            
            return {
                "success": False,
                "message": error_msg
            }
    
    @Slot(result='QVariant')
    def logout(self) -> Dict[str, Any]:
        """Logout current user"""
        try:
            result = self.auth_service.logout()
            
            self._current_user = None
            self._is_authenticated = False
            self._permissions = {}
            
            self.userChanged.emit()
            self.permissionChanged.emit()
            self.logoutResult.emit(result.success, result.message)
            
            return {
                "success": result.success,
                "message": result.message
            }
            
        except Exception as e:
            error_msg = f"Logout error: {str(e)}"
            logger.error(error_msg)
            self.logoutResult.emit(False, error_msg)
            
            return {
                "success": False,
                "message": error_msg
            }
    
    @Slot(str, str, result=bool)
    def hasPermission(self, resource: str, action: str) -> bool:
        """Check if current user has specific permission"""
        return self.auth_service.check_permission(resource, action)
    
    @Slot(result='QVariant')
    def getSessionInfo(self) -> Dict[str, Any]:
        """Get current session information"""
        return self.auth_service.get_session_info()


class ProductHandler(QObject):
    """QML handler for product operations"""
    
    # Signals
    productCreated = Signal('QVariant')  # product_data
    productUpdated = Signal('QVariant')  # product_data
    productDeleted = Signal(int)  # product_id
    productsLoaded = Signal('QVariant')  # products_list
    
    def __init__(self, product_service: ProductService, auth_service: AuthService):
        super().__init__()
        self.product_service = product_service
        self.auth_service = auth_service
    
    @Slot('QVariant', result='QVariant')
    def createProduct(self, product_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new product"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("products", "create")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.product_service.create_product(product_data)
            
            if result.success:
                self.productCreated.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Product creation error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(int, 'QVariant', result='QVariant')
    def updateProduct(self, product_id: int, update_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing product"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("products", "update")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            # Note: You'd implement update_product in ProductService
            # For now, we'll simulate it
            logger.info(f"Updating product {product_id} with data: {update_data}")
            
            # Simulate successful update
            updated_product = {"id": product_id, **update_data}
            self.productUpdated.emit(updated_product)
            
            return {
                "success": True,
                "message": "Product updated successfully",
                "data": updated_product
            }
            
        except Exception as e:
            error_msg = f"Product update error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(str, str, bool, int, result='QVariant')
    def searchProducts(
        self, 
        query: str = "", 
        category: str = "", 
        active_only: bool = True,
        limit: int = 50
    ) -> Dict[str, Any]:
        """Search products with filters"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("products", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.product_service.search_products(query, category, active_only, limit)
            
            if result.success:
                self.productsLoaded.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Product search error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(int, float, result='QVariant')
    def updateProductPrice(self, product_id: int, new_price: float) -> Dict[str, Any]:
        """Update product price"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("products", "update")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.product_service.update_product_price(product_id, Decimal(str(new_price)))
            
            if result.success:
                self.productUpdated.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Price update error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}


class CustomerHandler(QObject):
    """QML handler for customer operations"""
    
    # Signals
    customerCreated = Signal('QVariant')  # customer_data
    customerUpdated = Signal('QVariant')  # customer_data
    customersLoaded = Signal('QVariant')  # customers_list
    customerHistoryLoaded = Signal('QVariant')  # history_data
    
    def __init__(self, customer_service: CustomerService, auth_service: AuthService):
        super().__init__()
        self.customer_service = customer_service
        self.auth_service = auth_service
    
    @Slot('QVariant', result='QVariant')
    def createCustomer(self, customer_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new customer"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("customers", "create")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.customer_service.create_customer(customer_data)
            
            if result.success:
                self.customerCreated.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Customer creation error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(str, int, result='QVariant')
    def searchCustomers(self, query: str = "", limit: int = 50) -> Dict[str, Any]:
        """Search customers"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("customers", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.customer_service.search_customers(query, limit)
            
            if result.success:
                self.customersLoaded.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Customer search error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(int, result='QVariant')
    def getCustomerHistory(self, customer_id: int) -> Dict[str, Any]:
        """Get customer purchase history"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("customers", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.customer_service.get_customer_purchase_history(customer_id)
            
            if result.success:
                self.customerHistoryLoaded.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Customer history error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}


class SalesHandler(QObject):
    """QML handler for sales operations"""
    
    # Signals
    saleCreated = Signal('QVariant')  # sale_data
    salesLoaded = Signal('QVariant')  # sales_list
    saleUpdated = Signal('QVariant')  # sale_data
    
    def __init__(self, sales_service: SalesService, auth_service: AuthService):
        super().__init__()
        self.sales_service = sales_service
        self.auth_service = auth_service
    
    @Slot(int, 'QVariant', str, result='QVariant')
    def createSale(
        self, 
        customer_id: int, 
        items: List[Dict[str, Any]], 
        payment_method: str = "cash"
    ) -> Dict[str, Any]:
        """Create a new sale"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("sales", "create")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            # Get current user ID
            current_user = self.auth_service.get_current_user()
            user_id = current_user.user_id if current_user else None
            
            # Handle null customer_id (walk-in customer)
            customer_id = customer_id if customer_id > 0 else None
            
            result = self.sales_service.create_sale(customer_id, items, payment_method, user_id)
            
            if result.success:
                self.saleCreated.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Sale creation error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(str, str, result='QVariant')
    def getSalesByDateRange(self, start_date: str, end_date: str) -> Dict[str, Any]:
        """Get sales within date range"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("sales", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            # Parse dates
            start_dt = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
            end_dt = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
            
            # Get current user for filtering (if not admin)
            current_user = self.auth_service.get_current_user()
            user_id = None
            if current_user and current_user.role not in ["admin", "manager"]:
                user_id = current_user.user_id
            
            result = self.sales_service.get_sales_by_date_range(start_dt, end_dt, user_id)
            
            if result.success:
                self.salesLoaded.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Sales query error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}


class InventoryHandler(QObject):
    """QML handler for inventory operations"""
    
    # Signals
    inventoryUpdated = Signal('QVariant')  # inventory_data
    inventoryLoaded = Signal('QVariant')  # inventory_list
    lowStockAlert = Signal('QVariant')  # low_stock_items
    movementRecorded = Signal('QVariant')  # movement_data
    
    def __init__(self, inventory_service: InventoryService, auth_service: AuthService):
        super().__init__()
        self.inventory_service = inventory_service
        self.auth_service = auth_service
    
    @Slot(int, float, str, str, result='QVariant')
    def addInventory(
        self, 
        product_id: int, 
        quantity: float, 
        reason: str = "restock",
        notes: str = ""
    ) -> Dict[str, Any]:
        """Add inventory for a product"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("inventory", "update")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.inventory_service.add_inventory(
                product_id, Decimal(str(quantity)), reason, notes
            )
            
            if result.success:
                self.inventoryUpdated.emit(result.data)
                self.movementRecorded.emit({
                    "product_id": product_id,
                    "quantity": quantity,
                    "type": "inbound",
                    "reason": reason
                })
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Inventory update error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(result='QVariant')
    def getLowStockItems(self) -> Dict[str, Any]:
        """Get items with low stock levels"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("inventory", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.inventory_service.get_low_stock_items()
            
            if result.success:
                self.lowStockAlert.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Low stock query error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(int, str, int, result='QVariant')
    def getInventoryMovements(
        self, 
        product_id: int = 0, 
        movement_type: str = "", 
        limit: int = 100
    ) -> Dict[str, Any]:
        """Get inventory movement history"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("inventory", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            # Handle optional parameters
            product_id = product_id if product_id > 0 else None
            movement_type = movement_type if movement_type else None
            
            result = self.inventory_service.get_inventory_movements(product_id, movement_type, limit)
            
            if result.success:
                self.inventoryLoaded.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Inventory movements error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}


class ReportsHandler(QObject):
    """QML handler for reports and analytics"""
    
    # Signals
    reportGenerated = Signal('QVariant')  # report_data
    
    def __init__(self, report_service: ReportService, auth_service: AuthService):
        super().__init__()
        self.report_service = report_service
        self.auth_service = auth_service
    
    @Slot(str, str, result='QVariant')
    def getSalesSummary(self, start_date: str, end_date: str) -> Dict[str, Any]:
        """Generate sales summary report"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("reports", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            # Parse dates
            start_dt = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
            end_dt = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
            
            result = self.report_service.get_sales_summary(start_dt, end_dt)
            
            if result.success:
                self.reportGenerated.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Sales report error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}
    
    @Slot(result='QVariant')
    def getInventoryReport(self) -> Dict[str, Any]:
        """Generate inventory status report"""
        try:
            # Check permissions
            auth_check = self.auth_service.require_permission("reports", "read")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            result = self.report_service.get_inventory_report()
            
            if result.success:
                self.reportGenerated.emit(result.data)
            
            return result.to_dict()
            
        except Exception as e:
            error_msg = f"Inventory report error: {str(e)}"
            logger.error(error_msg)
            return {"success": False, "message": error_msg}


class SyncHandler(QObject):
    """QML handler for synchronization operations"""
    
    # Signals
    syncStarted = Signal()
    syncProgress = Signal(str, int)  # operation, percentage
    syncCompleted = Signal(bool, 'QVariant')  # success, result
    syncStatusChanged = Signal('QVariant')  # status_data
    
    def __init__(self, sync_manager: SyncManager, auth_service: AuthService):
        super().__init__()
        self.sync_manager = sync_manager
        self.auth_service = auth_service
        self._sync_in_progress = False
        
        # Timer for periodic sync status updates
        self.status_timer = QTimer()
        self.status_timer.timeout.connect(self._update_sync_status)
        self.status_timer.start(30000)  # Update every 30 seconds
    
    @Property(bool, notify=syncStatusChanged)
    def syncInProgress(self) -> bool:
        return self._sync_in_progress
    
    @Slot(result='QVariant')
    def startFullSync(self) -> Dict[str, Any]:
        """Start full bidirectional synchronization"""
        try:
            # Check permissions (admin only for manual sync)
            auth_check = self.auth_service.require_permission("settings", "update")
            if not auth_check.success:
                return {"success": False, "message": auth_check.errors[0]}
            
            if self._sync_in_progress:
                return {"success": False, "message": "Sync already in progress"}
            
            self._sync_in_progress = True
            self.syncStarted.emit()
            self.syncStatusChanged.emit({"sync_in_progress": True})
            
            # In a real implementation, this would be run in a separate thread
            # For now, we'll simulate it
            logger.info("Starting full synchronization")
            
            # Simulate sync progress
            QTimer.singleShot(1000, lambda: self.syncProgress.emit("Pulling remote changes", 25))
            QTimer.singleShot(2000, lambda: self.syncProgress.emit("Pushing local changes", 50))
            QTimer.singleShot(3000, lambda: self.syncProgress.emit("Resolving conflicts", 75))
            QTimer.singleShot(4000, lambda: self._complete_sync())
            
            return {"success": True, "message": "Sync started"}
            
        except Exception as e:
            error_msg = f"Sync start error: {str(e)}"
            logger.error(error_msg)
            self._sync_in_progress = False
            return {"success": False, "message": error_msg}
    
    def _complete_sync(self):
        """Simulate sync completion"""
        self._sync_in_progress = False
        self.syncProgress.emit("Sync completed", 100)
        
        # Simulate successful result
        result = {
            "synced_count": 25,
            "failed_count": 0,
            "conflicts_count": 1,
            "errors": []
        }
        
        self.syncCompleted.emit(True, result)
        self.syncStatusChanged.emit({"sync_in_progress": False})
        logger.info("Synchronization completed successfully")
    
    @Slot(result='QVariant')
    def getSyncStatus(self) -> Dict[str, Any]:
        """Get current synchronization status"""
        try:
            return self.sync_manager.get_sync_status()
        except Exception as e:
            logger.error(f"Sync status error: {str(e)}")
            return {"error": str(e)}
    
    def _update_sync_status(self):
        """Periodically update sync status"""
        try:
            status = self.getSyncStatus()
            self.syncStatusChanged.emit(status)
        except Exception as e:
            logger.error(f"Sync status update error: {str(e)}")


# Register QML types
def register_qml_types():
    """Register all QML types for use in QML"""
    qmlRegisterType(AuthHandler, "BusinessApp", 1, 0, "AuthHandler")
    qmlRegisterType(ProductHandler, "BusinessApp", 1, 0, "ProductHandler")
    qmlRegisterType(CustomerHandler, "BusinessApp", 1, 0, "CustomerHandler")
    qmlRegisterType(SalesHandler, "BusinessApp", 1, 0, "SalesHandler")
    qmlRegisterType(InventoryHandler, "BusinessApp", 1, 0, "InventoryHandler")
    qmlRegisterType(ReportsHandler, "BusinessApp", 1, 0, "ReportsHandler")
    qmlRegisterType(SyncHandler, "BusinessApp", 1, 0, "SyncHandler")
