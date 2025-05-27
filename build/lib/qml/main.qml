// Main QML file - Application entry point
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "screens"
import "components"
import "styles"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1200
    height: 800
    minimumWidth: 1024
    minimumHeight: 768
    title: "ChaOffice - Business Management System"
    
    property string currentScreen: "loading"
    property bool isInitialized: false
    
    // Apply theme
    color: Theme.backgroundColor
    
    // Global message popup for notifications
    MessagePopup {
        id: messagePopup
        parent: Overlay.overlay
    }
    
    // Main content stack to manage screens
    StackView {
        id: mainStack
        anchors.fill: parent
        initialItem: loadingScreen
        
        // Screen transitions
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
            }
        }
        
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 300
            }
        }
    }
    
    // Loading Screen Component
    Component {
        id: loadingScreen
        
        LoadingScreen {
            message: "Initializing ChaOffice..."
            progress: initTimer.progress
            
            Timer {
                id: initTimer
                interval: 100
                repeat: true
                running: true
                
                property real progress: 0.0
                
                onTriggered: {
                    progress += 0.05
                    if (progress >= 1.0) {
                        stop()
                        Qt.callLater(initializeApp)
                    }
                }
            }
        }
    }
    
    // Login Screen Component
    Component {
        id: loginScreen
        
        LoginScreen {
            onLoginRequested: function(email, password) {
                isLoading = true
                // Simulate login process
                loginTimer.email = email
                loginTimer.password = password
                loginTimer.start()
            }
            
            onOfflineModeRequested: {
                console.log("Switching to offline mode")
                if (typeof appBridge !== "undefined") {
                    appBridge.configHandler.setOnlineMode(false)
                }
                showMainApplication()
            }
            
            Timer {
                id: loginTimer
                interval: 2000
                
                property string email: ""
                property string password: ""
                
                onTriggered: {
                    var loginItem = mainStack.currentItem
                    if (email === "admin@example.com" && password === "admin") {
                        console.log("Login successful")
                        if (typeof appBridge !== "undefined") {
                            appBridge.configHandler.setOnlineMode(true)
                        }
                        showMainApplication()
                    } else {
                        loginItem.isLoading = false
                        loginItem.errorMessage = "Invalid email or password"
                    }
                }
            }
        }
    }
    
    // Main Application Component
    Component {
        id: mainApplication
        
        MainApplication {
            currentUser: typeof appBridge !== "undefined" ? "admin@example.com" : "Guest User"
            isOnlineMode: typeof appBridge !== "undefined" ? appBridge.configHandler.isOnline : false
            
            onLogoutRequested: {
                console.log("Logout requested")
                mainStack.replace(loginScreen)
                messagePopup.title = "Logged Out"
                messagePopup.message = "You have been logged out successfully"
                messagePopup.type = "info"
                messagePopup.open()
            }
            
            onViewChanged: function(viewName) {
                console.log("View changed to:", viewName)
            }
        }
    }
    
    // Handle authentication state changes from Python bridge
    Connections {
        target: typeof appBridge !== "undefined" ? appBridge.authHandler : null
        
        function onLoginSuccess() {
            messagePopup.title = "Login Successful"
            messagePopup.message = "Welcome to ChaOffice!"
            messagePopup.type = "success"
            messagePopup.open()
            showMainApplication()
        }
        
        function onLoginFailed(errorMsg) {
            messagePopup.title = "Login Failed"
            messagePopup.message = errorMsg
            messagePopup.type = "error"
            messagePopup.open()
            
            if (mainStack.currentItem && typeof mainStack.currentItem.isLoading !== "undefined") {
                mainStack.currentItem.isLoading = false
                mainStack.currentItem.errorMessage = errorMsg
            }
        }
        
        function onLoggedOut() {
            messagePopup.title = "Logged Out"
            messagePopup.message = "You have been logged out"
            messagePopup.type = "info"
            messagePopup.open()
            mainStack.replace(loginScreen)
        }
    }
    
    // Handle product operations
    Connections {
        target: typeof appBridge !== "undefined" ? appBridge.productHandler : null
        
        function onProductsFetched() {
            console.log("Products fetched successfully")
        }
        
        function onProductsFetchFailed(errorMsg) {
            messagePopup.title = "Error"
            messagePopup.message = "Failed to load products: " + errorMsg
            messagePopup.type = "error"
            messagePopup.open()
        }
        
        function onProductOperationComplete(message) {
            console.log("Product operation:", message)
            messagePopup.title = "Success"
            messagePopup.message = message
            messagePopup.type = "success"
            messagePopup.open()
        }
    }
    
    // Handle configuration changes
    Connections {
        target: typeof appBridge !== "undefined" ? appBridge.configHandler : null
        
        function onIsOnlineChanged() {
            var mode = appBridge.configHandler.isOnline ? "Online" : "Offline"
            console.log("Mode changed to:", mode)
            
            if (mainStack.currentItem && typeof mainStack.currentItem.isOnlineMode !== "undefined") {
                mainStack.currentItem.isOnlineMode = appBridge.configHandler.isOnline
            }
        }
        
        function onThemeColorsChanged() {
            console.log("Theme changed")
            // Theme changes are handled automatically by the Theme singleton
        }
    }
    
    // Helper functions
    function initializeApp() {
        console.log("Initializing application...")
        isInitialized = true
        
        // Check if we have a saved login state
        if (typeof appBridge !== "undefined" && appBridge.authHandler.isLoggedIn) {
            console.log("User already logged in")
            showMainApplication()
        } else {
            console.log("Showing login screen")
            mainStack.replace(loginScreen)
        }
    }
    
    function showMainApplication() {
        currentScreen = "main"
        mainStack.replace(mainApplication)
    }
    
    function showLoginScreen() {
        currentScreen = "login"
        mainStack.replace(loginScreen)
    }
    
    // Global keyboard shortcuts
    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }
    
    Shortcut {
        sequence: "Ctrl+,"
        onActivated: {
            if (currentScreen === "main" && mainStack.currentItem) {
                mainStack.currentItem.setCurrentView("settings")
            }
        }
    }
    
    // Window close event
    onClosing: function(close) {
        console.log("Application closing...")
        
        // Perform cleanup if needed
        if (typeof appBridge !== "undefined") {
            // Save any pending changes
            console.log("Performing cleanup...")
        }
        
        close.accepted = true
    }
    
    // Component initialization
    Component.onCompleted: {
        console.log("Main window loaded")
        console.log("AppBridge available:", typeof appBridge !== "undefined")
        
        // Set up theme
        if (typeof appBridge !== "undefined") {
            Theme.isDarkMode = appBridge.configHandler.currentTheme === "dark"
        }
    }
}
