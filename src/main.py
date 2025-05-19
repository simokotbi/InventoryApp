import sys
import os
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, Property, QUrl
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType
from PySide6.QtWidgets import QApplication
from PySide6.QtQuick import QQuickWindow

from authentication.auth_service import AuthService
from database.database import Database
from utils.logger import get_logger
from utils.config_manager import ConfigManager

logger = get_logger()
config = ConfigManager()

class AuthHandler(QObject):
    loginStatusChanged = Signal(bool, str)
    userDataChanged = Signal(str, str)  # username, email

    def __init__(self):
        super().__init__()
        self.auth_service = AuthService()
        self._is_logged_in = False
        self._current_user = None
        logger.info("AuthHandler initialized")

    @Slot(str, str, str, result='QVariant')
    def register(self, username: str, email: str, password: str):
        logger.debug(f"Registration attempt for username: {username}")
        success, message = self.auth_service.register(username, email, password)
        return {"success": success, "message": message}

    @Slot(str, str, result='QVariant')
    def login(self, username: str, password: str):
        logger.debug(f"Login attempt for username: {username}")
        success, message, user_data = self.auth_service.login(username, password)
        if success and user_data:
            self._is_logged_in = True
            self._current_user = user_data
            self.loginStatusChanged.emit(True, message)
            self.userDataChanged.emit(user_data['username'], user_data['email'])
            logger.info(f"User logged in successfully: {username}")
        else:
            self._is_logged_in = False
            self._current_user = None
            self.loginStatusChanged.emit(False, message)
            logger.warning(f"Login failed for username: {username}")
        return {"success": success, "message": message}

    @Slot()
    def logout(self):
        if self._current_user:
            logger.info(f"User logged out: {self._current_user.get('username')}")
        self._is_logged_in = False
        self._current_user = None
        self.loginStatusChanged.emit(False, "Logged out")

    @Property(bool)
    def isLoggedIn(self):
        return self._is_logged_in

def register_types():
    # Register Theme singleton
    qml_dir = os.path.join(Path(__file__).parent, "qml")
    theme_url = QUrl.fromLocalFile(os.path.join(qml_dir, "styles", "Theme.qml"))
    
    def theme_singleton(engine):
        from PySide6.QtQml import QQmlComponent
        component = QQmlComponent(engine)
        component.loadUrl(theme_url)
        if component.isError():
            for error in component.errors():
                logger.error(f"Theme loading error: {error.toString()}")
            return None
        theme_instance = component.create()
        if not theme_instance:
            logger.error("Failed to create Theme instance")
            return None
        return theme_instance

    qmlRegisterSingletonType(
        QObject,
        "Theme",
        1, 0,
        "Theme",
        theme_singleton
    )

def main():
    logger.info("Application starting...")
    
    # Set Material style for the application
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    try:
        # Register types
        register_types()
        logger.debug("QML types registered successfully")

        # Create and register the auth handler
        auth_handler = AuthHandler()
        engine.rootContext().setContextProperty("authHandler", auth_handler)

        # Set up QML import paths
        qml_dir = os.path.join(Path(__file__).parent, "qml")
        engine.addImportPath(qml_dir)

        # Load the main QML file
        qml_file = os.path.join(qml_dir, "pages", "SigninPage.qml")
        url = QUrl.fromLocalFile(qml_file)
        engine.load(url)

        if not engine.rootObjects():
            logger.error(f"Failed to load QML file: {qml_file}")
            return -1

        logger.info("Application loaded successfully")
        return app.exec()

    except Exception as e:
        logger.error(f"Application error: {str(e)}", exc_info=True)
        return -1

if __name__ == "__main__":
    sys.exit(main())