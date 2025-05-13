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
        source: "LoginPage.qml" // Default page is LoginPage
    }

    Connections {
        target: LoginManager

        function onLoginSuccess() {
            pageLoader.source = "Main.qml"; // Load main app after successful login
        }
    }

    Connections {
        target: pageLoader

        // Connect sidebar signals to load different pages
        function onLoadDashboardPage() {
            pageLoader.source = "DashboardPage.qml"; // Load Dashboard page
        }

        function onLoadSettingsPage() {
            pageLoader.source = "SettingsPage.qml"; // Load Settings page
        }

        function onLoadReportsPage() {
            pageLoader.source = "ReportsPage.qml"; // Load Reports page
        }
    }
}