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
                          Rectangle {
                            width: parent.width
                            height: 48
                            color: root.currentView === "dashboard" ? Theme.primaryColorLight : 
                                   (dashboardMouse.containsMouse ? Theme.hoverColor : "transparent")
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacing
                                
                                SvgIcon {
                                    source: "qrc:/assets/icons/dashboard.svg"
                                    size: 20
                                    color: root.currentView === "dashboard" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: "Dashboard"
                                    font.pixelSize: Theme.fontSize
                                    color: root.currentView === "dashboard" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                id: dashboardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setCurrentView("dashboard")
                            }
                        }
                          Rectangle {
                            width: parent.width
                            height: 48
                            color: root.currentView === "products" ? Theme.primaryColorLight : 
                                   (productsMouse.containsMouse ? Theme.hoverColor : "transparent")
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacing
                                
                                SvgIcon {
                                    source: "qrc:/assets/icons/package.svg"
                                    size: 20
                                    color: root.currentView === "products" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: "Products"
                                    font.pixelSize: Theme.fontSize
                                    color: root.currentView === "products" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                id: productsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setCurrentView("products")
                            }
                        }
                          
                        Rectangle {
                            width: parent.width
                            height: 48
                            color: root.currentView === "sales" ? Theme.primaryColorLight : 
                                   (salesMouse.containsMouse ? Theme.hoverColor : "transparent")
                            enabled: root.isOnlineMode
                            opacity: enabled ? 1.0 : 0.5
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacing
                                
                                SvgIcon {
                                    source: "qrc:/assets/icons/trending-up.svg"
                                    size: 20
                                    color: root.currentView === "sales" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: parent.parent.enabled ? 1.0 : 0.5
                                }
                                
                                Text {
                                    text: "Sales"
                                    font.pixelSize: Theme.fontSize
                                    color: root.currentView === "sales" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: parent.parent.enabled ? 1.0 : 0.5
                                }
                            }
                            
                            MouseArea {
                                id: salesMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: parent.enabled
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: if (enabled) root.setCurrentView("sales")                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 48
                            color: root.currentView === "customers" ? Theme.primaryColorLight : 
                                   (customersMouse.containsMouse ? Theme.hoverColor : "transparent")
                            enabled: root.isOnlineMode
                            opacity: enabled ? 1.0 : 0.5
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacing
                                
                                SvgIcon {
                                    source: "qrc:/assets/icons/users.svg"
                                    size: 20
                                    color: root.currentView === "customers" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: parent.parent.enabled ? 1.0 : 0.5
                                }
                                
                                Text {
                                    text: "Customers"
                                    font.pixelSize: Theme.fontSize
                                    color: root.currentView === "customers" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: parent.parent.enabled ? 1.0 : 0.5
                                }
                            }
                            
                            MouseArea {
                                id: customersMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: parent.enabled
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: if (enabled) root.setCurrentView("customers")
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.borderColor
                        }
                          Rectangle {
                            width: parent.width
                            height: 48
                            color: root.currentView === "settings" ? Theme.primaryColorLight : 
                                   (settingsMouse.containsMouse ? Theme.hoverColor : "transparent")
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacing
                                
                                SvgIcon {
                                    source: "qrc:/assets/icons/settings.svg"
                                    size: 20
                                    color: root.currentView === "settings" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: "Settings"
                                    font.pixelSize: Theme.fontSize
                                    color: root.currentView === "settings" ? Theme.primaryColor : Theme.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                id: settingsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setCurrentView("settings")
                            }
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
                        case "dashboard": return 0;
                        case "products": return 1;
                        case "settings": return 2;
                        case "sales": return 3; // Added for Sales view
                        case "customers": return 4; // Added for Customers view
                        default: return 0;
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

                // Placeholder for Sales View
                Item {
                    Text {
                        anchors.centerIn: parent
                        text: "Sales View (Not Implemented)"
                        font.pixelSize: Theme.fontSizeXLarge
                        color: Theme.textColor
                    }
                }

                // Placeholder for Customers View
                Item {
                    Text {
                        anchors.centerIn: parent
                        text: "Customers View (Not Implemented)"
                        font.pixelSize: Theme.fontSizeXLarge
                        color: Theme.textColor
                    }
                }
            }
        }
    }
      function setCurrentView(viewName) {
        root.currentView = viewName
        root.viewChanged(viewName)
    }
}
