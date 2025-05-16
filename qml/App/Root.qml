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

    // Load the sidebar component
    Loader {
        id: sidebarLoader
        source: "Sidebar.qml" // Ensure this is the correct path
    }

    Connections {
        target: LoginManager

        function onLoginSuccess() {
            pageLoader.source = "Main.qml"; // Load main app after successful login
        }
    }

    // Add a connection to handle Sidebar signals
    Connections {
        target: sidebarLoader.item // Use item property to reference the loaded Sidebar
        function onLoadDashboardPage() {
            pageLoader.source = "DashboardPage.qml"; // Load Dashboard page
        }
    }
}