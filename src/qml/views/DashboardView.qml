import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"
import "../components"

Rectangle {
    id: root
    
    property bool isOnlineMode: true
    
    color: Theme.backgroundColor
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing * 2
        
        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing * 2
            
            // Header
            Text {
                text: "Dashboard"
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.textColor
                Layout.fillWidth: true
            }
            
            // Stats cards
            GridLayout {
                columns: width > 800 ? 4 : 2
                rowSpacing: Theme.spacing
                columnSpacing: Theme.spacing
                Layout.fillWidth: true
                
                StatsCard {
                    title: "Total Products"
                    value: "156"
                    icon: "qrc:/assets/icons/package.svg"
                    color: Theme.primaryColor
                    Layout.fillWidth: true
                }
                
                StatsCard {
                    title: "Today's Sales"
                    value: root.isOnlineMode ? "$2,450" : "Offline"
                    icon: "qrc:/assets/icons/dollar-sign.svg"
                    color: "#4CAF50"
                    enabled: root.isOnlineMode
                    Layout.fillWidth: true
                }
                
                StatsCard {
                    title: "Active Orders"
                    value: root.isOnlineMode ? "23" : "Offline"
                    icon: "qrc:/assets/icons/shopping-cart.svg"
                    color: "#FF9800"
                    enabled: root.isOnlineMode
                    Layout.fillWidth: true
                }
                
                StatsCard {
                    title: "Low Stock Items"
                    value: "8"
                    icon: "qrc:/assets/icons/alert-triangle.svg"
                    color: "#F44336"
                    Layout.fillWidth: true
                }
            }
            
            // Quick actions
            GroupBox {
                title: "Quick Actions"
                Layout.fillWidth: true
                
                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.spacing
                      CustomButton {
                        text: "Add Product"
                        variant: "primary"
                        Layout.preferredWidth: 150
                        onClicked: console.log("Add product clicked")
                    }
                    
                    CustomButton {
                        text: "New Sale"
                        variant: "secondary"
                        enabled: root.isOnlineMode
                        Layout.preferredWidth: 150
                        onClicked: console.log("New sale clicked")
                    }
                    
                    CustomButton {
                        text: "Sync Data"
                        primary: false
                        enabled: !root.isOnlineMode
                        Layout.preferredWidth: 150
                        onClicked: console.log("Sync data clicked")
                    }
                    
                    Item { Layout.fillWidth: true }
                }
            }
            
            // Recent activity
            GroupBox {
                title: "Recent Activity"
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                ListView {
                    anchors.fill: parent
                    model: ListModel {
                        ListElement {
                            type: "product"
                            title: "New product added"
                            description: "Gaming Mouse X1"
                            time: "2 minutes ago"
                            icon: "qrc:/assets/icons/plus.svg"
                        }
                        ListElement {
                            type: "sale"
                            title: "Sale completed"
                            description: "$45.99 - Wireless Keyboard"
                            time: "15 minutes ago"
                            icon: "qrc:/assets/icons/dollar-sign.svg"
                        }
                        ListElement {
                            type: "stock"
                            title: "Low stock alert"
                            description: "USB Cable - Only 5 left"
                            time: "1 hour ago"
                            icon: "qrc:/assets/icons/alert-triangle.svg"
                        }
                        ListElement {
                            type: "sync"
                            title: "Data synchronized"
                            description: "Local database updated"
                            time: "2 hours ago"
                            icon: "qrc:/assets/icons/refresh-cw.svg"
                        }
                    }
                    
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 60
                        color: index % 2 === 0 ? "transparent" : Theme.alternateBackgroundColor
                        
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacing
                            
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: {
                                    switch(model.type) {
                                        case "product": return Theme.primaryColor
                                        case "sale": return "#4CAF50"
                                        case "stock": return "#F44336"
                                        case "sync": return "#2196F3"
                                        default: return Theme.textColorSecondary
                                    }
                                }
                                anchors.verticalCenter: parent.verticalCenter
                                
                                SvgIcon {
                                    anchors.centerIn: parent
                                    source: model.icon
                                    size: 20
                                    color: "white"
                                }
                            }
                            
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                
                                Text {
                                    text: model.title
                                    font.pixelSize: Theme.fontSize
                                    font.weight: Font.Medium
                                    color: Theme.textColor
                                }
                                
                                Text {
                                    text: model.description
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.textColorSecondary
                                }
                            }
                            
                            Item { width: 20 }
                            
                            Text {
                                text: model.time
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textColorSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    
                    // Empty state
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: 150
                        color: "transparent"
                        visible: parent.count === 0
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacing
                            
                            SvgIcon {
                                source: "qrc:/assets/icons/activity.svg"
                                size: 48
                                color: Theme.textColorSecondary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "No recent activity"
                                font.pixelSize: Theme.fontSize
                                color: Theme.textColorSecondary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
