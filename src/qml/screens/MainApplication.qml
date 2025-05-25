import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Temporarily disabled

Item {
    id: mainApp
    
    // Navigation state
    property string currentView: "dashboard"
    
    // User info
    property var currentUser: authHandler.currentUser
    
    // Component loading state
    property bool isLoading: false
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: themeManager.backgroundColor
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Sidebar Navigation
        Rectangle {
            id: sidebar
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: themeManager.primaryColor
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8
                
                // User info header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "transparent"
                    border.color: themeManager.dividerColor
                    border.width: 1
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        // User avatar
                        Rectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            color: themeManager.accentColor
                            radius: 25
                            
                            Text {
                                anchors.centerIn: parent
                                text: currentUser ? currentUser.username.charAt(0).toUpperCase() : "U"
                                color: "white"
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }
                        
                        // User details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: currentUser ? currentUser.username : "User"
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Text {
                                text: currentUser ? currentUser.role : "user"
                                color: themeManager.surfaceColor
                                font.pixelSize: 12
                                opacity: 0.8
                            }
                        }
                    }
                }
                
                // Navigation menu
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 4
                        
                        // Dashboard
                        NavigationItem {
                            icon: "📊"
                            text: "Dashboard"
                            isActive: mainApp.currentView === "dashboard"
                            onClicked: mainApp.currentView = "dashboard"
                        }
                        
                        // Products
                        NavigationItem {
                            icon: "📦"
                            text: "Products"
                            isActive: mainApp.currentView === "products"
                            onClicked: mainApp.currentView = "products"
                        }
                        
                        // Customers
                        NavigationItem {
                            icon: "👥"
                            text: "Customers"
                            isActive: mainApp.currentView === "customers"
                            onClicked: mainApp.currentView = "customers"
                        }
                        
                        // Sales
                        NavigationItem {
                            icon: "💰"
                            text: "Sales"
                            isActive: mainApp.currentView === "sales"
                            onClicked: mainApp.currentView = "sales"
                        }
                        
                        // Inventory
                        NavigationItem {
                            icon: "📋"
                            text: "Inventory"
                            isActive: mainApp.currentView === "inventory"
                            onClicked: mainApp.currentView = "inventory"
                        }
                        
                        // Reports (Admin/Manager only)
                        NavigationItem {
                            icon: "📈"
                            text: "Reports"
                            isActive: mainApp.currentView === "reports"
                            visible: currentUser && (currentUser.role === "admin" || currentUser.role === "manager")
                            onClicked: mainApp.currentView = "reports"
                        }
                        
                        // Settings (Admin only)
                        NavigationItem {
                            icon: "⚙️"
                            text: "Settings"
                            isActive: mainApp.currentView === "settings"
                            visible: currentUser && currentUser.role === "admin"
                            onClicked: mainApp.currentView = "settings"
                        }
                        
                        // Spacer
                        Item {
                            Layout.fillHeight: true
                        }
                        
                        // Sync status
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "transparent"
                            border.color: themeManager.dividerColor
                            border.width: 1
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                Text {
                                    text: syncHandler.isOnline ? "🟢" : "🔴"
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: syncHandler.isOnline ? "Online" : "Offline"
                                    color: "white"
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                }
                                
                                Button {
                                    text: "Sync"
                                    enabled: syncHandler.isOnline && !syncHandler.isSyncing
                                    Material.background: themeManager.accentColor
                                    Material.foreground: "white"
                                    font.pixelSize: 10
                                    onClicked: syncHandler.syncAll()
                                }
                            }
                        }
                        
                        // Logout button
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            text: "Logout"
                            Material.background: themeManager.errorColor
                            Material.foreground: "white"
                            font.pixelSize: 14
                            onClicked: authHandler.logout()
                        }
                    }
                }
            }
        }
        
        // Main content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: themeManager.backgroundColor
            
            StackView {
                id: contentStack
                anchors.fill: parent
                anchors.margins: 16
                
                // Loading overlay
                Loader {
                    visible: mainApp.isLoading
                    anchors.centerIn: parent
                    sourceComponent: BusyIndicator {
                        Material.accent: themeManager.primaryColor
                        running: true
                    }
                }
                
                // Main content based on current view
                Component.onCompleted: updateContent()
                
                Connections {
                    target: mainApp
                    function onCurrentViewChanged() {
                        updateContent()
                    }
                }
                
                function updateContent() {
                    var component
                    switch(mainApp.currentView) {
                        case "dashboard":
                            component = "views/DashboardView.qml"
                            break
                        case "products":
                            component = "views/ProductsView.qml"
                            break
                        case "customers":
                            component = "views/CustomersView.qml"
                            break
                        case "sales":
                            component = "views/SalesView.qml"
                            break
                        case "inventory":
                            component = "views/InventoryView.qml"
                            break
                        case "reports":
                            component = "views/ReportsView.qml"
                            break
                        case "settings":
                            component = "views/SettingsView.qml"
                            break
                        default:
                            component = "views/DashboardView.qml"
                    }
                    
                    if (contentStack.currentItem === null || contentStack.currentItem.objectName !== mainApp.currentView) {
                        contentStack.replace(component)
                        if (contentStack.currentItem) {
                            contentStack.currentItem.objectName = mainApp.currentView
                        }
                    }
                }
            }
        }
    }
}
