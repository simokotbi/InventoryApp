from pathlib import Path
import sys
from PySide6.QtCore import QStringListModel, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot

from PySide6.QtLocation import QGeoServiceProvider
from PySide6.QtPositioning import QGeoCoordinate



class LoginManager(QObject):
    loginSuccess = Signal()
    loginFailed = Signal()

    @Slot(str, str)
    def verify_login(self, username, password):
        print(f"Checking login for {username}")
        if username == "a" and password == "a":
            self.loginSuccess.emit()
            print("hellllloooooowwww")
        else:
            self.loginFailed.emit()

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Prepare paths nicely
    BASE_DIR = Path(__file__).parent
    QML_DIR = BASE_DIR / "qml"

    # Add import paths
    engine.addImportPath(str(QML_DIR))
    engine.addImportPath(str(QML_DIR / "Themestyles"))
    engine.addImportPath(str(QML_DIR / "Components"))
    engine.addImportPath(str(QML_DIR / "Layouts"))


    # Expose model
    brands = ["bmw", "mercedes", "honda"]
    brands.sort()
    my_model = QStringListModel(brands)
    engine.rootContext().setContextProperty("myModel", my_model)

    # Expose login manager
    login_manager = LoginManager()
    engine.rootContext().setContextProperty("LoginManager", login_manager)

    # Load Main.qml
    engine.load(QUrl.fromLocalFile(str(QML_DIR / "App" / "Root.qml")))


    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
