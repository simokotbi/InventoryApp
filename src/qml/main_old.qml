import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
// import BusinessApp 1.0  // Temporarily disabled
import "screens" as Screens

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    title: "Business Management System - ChaOffice"
    
    // Application state
    property bool isLoading: true
    property bool isAuthenticated: authHandler.isAuthenticated
      // Theme integration
    color: themeManager.backgroundColor
    
    // Watch for authentication changes
    Connections {
        target: authHandler
        function onIsAuthenticatedChanged() {
            updateMainContent()
        }
    }
    
    // Main content loader
    StackView {
        id: mainStack
        anchors.fill: parent
          // Initial loading screen
        initialItem: Screens.LoadingScreen {
            onLoadingComplete: {
                mainWindow.isLoading = false
                updateMainContent()
            }
        }
          // Update content based on authentication state
        function updateMainContent() {
            if (mainWindow.isLoading) return
            
            if (mainWindow.isAuthenticated) {
                if (mainStack.currentItem && mainStack.currentItem.objectName === "mainApp") {
                    return // Already showing main app
                }
                mainStack.replace("screens/MainApplication.qml")
                if (mainStack.currentItem) {
                    mainStack.currentItem.objectName = "mainApp"
                }
            } else {
                if (mainStack.currentItem && mainStack.currentItem.objectName === "loginScreen") {
                    return // Already showing login
                }
                mainStack.replace("screens/LoginScreen.qml")
                if (mainStack.currentItem) {
                    mainStack.currentItem.objectName = "loginScreen"
                }
            }
        }
    }
    
    // Global connections
    Connections {
        target: authHandler
        function onLoginResult(success, message, userData) {
            if (success) {
                console.log("Login successful:", message)
            } else {
                console.log("Login failed:", message)
            }
        }
        
        function onLogoutResult(success, message) {
            console.log("Logout:", message)
        }
    }
    
    // Application startup
    Component.onCompleted: {
        console.log("Business Management Application started")
        
        // Check for existing session
        var sessionInfo = authHandler.getSessionInfo()
        if (sessionInfo.is_authenticated) {
            mainWindow.isAuthenticated = true
        }
    }
}
