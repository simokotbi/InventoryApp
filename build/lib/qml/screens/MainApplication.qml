import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"
import "../components"
import "../views"

Rectangle {
    id: root
    
    property string currentUser: ""
    property bool isOnlineMode: true
    property string currentView: "dashboard"
    
    signal logoutRequested()
    signal viewChanged(string viewName)
    
    color: Theme.backgroundColor
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Sidebar
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: Theme.sidebarColor
            border.color: Theme.borderColor
            border.width: 1
            
            Column {
                anchors.fill: parent
                
                // Header
                Rectangle {
                    width: parent.width
                    height: 80
                    color: Theme.primaryColor
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacing
                        
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                anchors.centerIn: parent
                                text: "CO"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: Theme.primaryColor
                            }
                        }
                        
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "ChaOffice"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Bold
                                color: "white"
                            }
                            
                            Text {
                                text: root.isOnlineMode ? "Online" : "Offline"
                                font.pixelSize: Theme.fontSizeSmall
                                color: "white"
                                opacity: 0.8
                            }
                        }
                    }
                }
                
                // Navigation
                ScrollView {
                    width: parent.width
                    height: parent.height - 80 - 120
                    
                    Column {
                        width: parent.width
                        
                        NavigationItem {
                            text: "Dashboard"
                            icon: "qrc:/assets/icons/dashboard.svg"
                            active: root.currentView === "dashboard"
                            onClicked: root.setCurrentView("dashboard")
                        }
                        
                        NavigationItem {
                            text: "Products"
                            icon: "qrc:/assets/icons/package.svg"
                            active: root.currentView === "products"
                            onClicked: root.setCurrentView("products")
                        }
                        
                        NavigationItem {
                            text: "Sales"
                            icon: "qrc:/assets/icons/trending-up.svg"
                            active: root.currentView === "sales"
                            onClicked: root.setCurrentView("sales")
                            enabled: root.isOnlineMode
                        }
                        
                        NavigationItem {
                            text: "Customers"
                            icon: "qrc:/assets/icons/users.svg"
                            active: root.currentView === "customers"
                            onClicked: root.setCurrentView("customers")
                            enabled: root.isOnlineMode
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.borderColor
                        }
                        
                        NavigationItem {
                            text: "Settings"
                            icon: "qrc:/assets/icons/settings.svg"
                            active: root.currentView === "settings"
                            onClicked: root.setCurrentView("settings")
                        }
                    }
                }
                
                // User info and logout
                Rectangle {
                    width: parent.width
                    height: 120
                    color: Theme.headerColor
                    border.color: Theme.borderColor
                    border.width: 1
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSmall
                        
                        Row {
                            spacing: Theme.spacing
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Theme.primaryColor
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: root.currentUser.length > 0 ? root.currentUser.charAt(0).toUpperCase() : "U"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: "white"
                                }
                            }
                            
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text {
                                    text: root.currentUser || "Guest User"
                                    font.pixelSize: Theme.fontSize
                                    font.weight: Font.Medium
                                    color: Theme.textColor
                                }
                                
                                Text {
                                    text: root.isOnlineMode ? "Online Mode" : "Offline Mode"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.textColorSecondary
                                }
                            }
                        }
                        
                        CustomButton {
                            text: "Logout"
                            width: parent.width - Theme.spacing * 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            primary: false
                            
                            onClicked: root.logoutRequested()
                        }
                    }
                }
            }
        }
        
        // Main content
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.backgroundColor
            
            StackLayout {
                id: contentStack
                anchors.fill: parent
                currentIndex: {
                    switch(root.currentView) {
                        case "dashboard": return 0
                        case "products": return 1
                        case "settings": return 2
                        default: return 0
                    }
                }
                
                DashboardView {
                    id: dashboardView
                    isOnlineMode: root.isOnlineMode
                }
                
                ProductsView {
                    id: productsView
                    isOnlineMode: root.isOnlineMode
                }
                
                SettingsView {
                    id: settingsView
                    isOnlineMode: root.isOnlineMode
                    onThemeChanged: Theme.isDarkMode = isDark
                    onOnlineModeToggled: root.isOnlineMode = enabled
                }
            }
        }
    }
    
    function setCurrentView(viewName) {
        root.currentView = viewName
        root.viewChanged(viewName)
    }
    
    // Navigation item component
    Component {
        id: navigationItemComponent
        
        Rectangle {
            property string text: ""
            property string icon: ""
            property bool active: false
            property bool enabled: true
            
            signal clicked()
            
            width: parent.width
            height: 48
            color: active ? Theme.primaryColorLight : (mouseArea.containsMouse ? Theme.hoverColor : "transparent")
            
            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing
                
                SvgIcon {
                    source: icon
                    size: 20
                    color: enabled ? (active ? Theme.primaryColor : Theme.textColor) : Theme.disabledColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: parent.parent.parent.text
                    font.pixelSize: Theme.fontSize
                    color: enabled ? (active ? Theme.primaryColor : Theme.textColor) : Theme.disabledColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: parent.enabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: parent.clicked()
            }
        }
    }
}

// Helper component for navigation items
Item {
    id: navigationItem
    
    property string text: ""
    property string icon: ""
    property bool active: false
    property bool enabled: true
    
    signal clicked()
    
    width: parent ? parent.width : 0
    height: 48
    
    Rectangle {
        anchors.fill: parent
        color: navigationItem.active ? Theme.primaryColorLight : 
               (mouseArea.containsMouse ? Theme.hoverColor : "transparent")
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing
            
            SvgIcon {
                source: navigationItem.icon
                size: 20
                color: navigationItem.enabled ? 
                       (navigationItem.active ? Theme.primaryColor : Theme.textColor) : 
                       Theme.disabledColor
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: navigationItem.text
                font.pixelSize: Theme.fontSize
                color: navigationItem.enabled ? 
                       (navigationItem.active ? Theme.primaryColor : Theme.textColor) : 
                       Theme.disabledColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: navigationItem.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: navigationItem.clicked()
        }
    }
}
