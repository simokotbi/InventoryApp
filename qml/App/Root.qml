import QtQuick 2.15
import QtQuick.Controls 2.15
import App 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Login App Example"

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: "LoginPage.qml"   
    }

    Connections {
        target: LoginManager

        function onLoginSuccess() {
            pageLoader.source = "Main.qml"; // Load main app after successful login
        }
    }
}
