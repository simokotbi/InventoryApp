import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

ScrollView {
    id: dashboardView
    
    property var dashboardData: reportsHandler.dashboardData
    
    Component.onCompleted: {
        reportsHandler.loadDashboardData()
    }
    
    ColumnLayout {
        width: parent.width
        spacing: 24
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Dashboard"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            Text {
                text: new Date().toLocaleDateString()
                font.pixelSize: 14
                color: themeManager.secondaryTextColor
            }
        }
        
        // Stats cards
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            
            // Total Sales
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Total Sales"
                value: dashboardData ? "$" + (dashboardData.total_sales || 0).toLocaleString() : "$0"
                icon: "💰"
                color: themeManager.primaryColor
                change: dashboardData ? dashboardData.sales_change || 0 : 0
            }
            
            // Total Products
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Products"
                value: dashboardData ? (dashboardData.total_products || 0).toString() : "0"
                icon: "📦"
                color: themeManager.accentColor
                change: dashboardData ? dashboardData.products_change || 0 : 0
            }
            
            // Total Customers
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Customers"
                value: dashboardData ? (dashboardData.total_customers || 0).toString() : "0"
                icon: "👥"
                color: "#FF9800"
                change: dashboardData ? dashboardData.customers_change || 0 : 0
            }
            
            // Low Stock Items
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Low Stock"
                value: dashboardData ? (dashboardData.low_stock_items || 0).toString() : "0"
                icon: "⚠️"
                color: themeManager.errorColor
                isWarning: true
            }
        }
        
        // Charts and recent activity
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            spacing: 16
            
            // Sales chart placeholder
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    
                    Text {
                        text: "Sales Overview"
                        font.pixelSize: 18
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "📈 Chart Coming Soon"
                            font.pixelSize: 24
                            color: themeManager.secondaryTextColor
                        }
                    }
                }
            }
            
            // Recent sales
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    
                    Text {
                        text: "Recent Sales"
                        font.pixelSize: 18
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        model: dashboardData ? dashboardData.recent_sales || [] : []
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 60
                            color: "transparent"
                            border.color: themeManager.dividerColor
                            border.width: index < parent.count - 1 ? 1 : 0
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    color: themeManager.primaryColor
                                    radius: 20
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "💰"
                                        font.pixelSize: 16
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.customer_name || "Unknown Customer"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: themeManager.textColor
                                    }
                                    
                                    Text {
                                        text: "$" + (modelData.total || 0).toFixed(2)
                                        font.pixelSize: 12
                                        color: themeManager.secondaryTextColor
                                    }
                                }
                                
                                Text {
                                    text: new Date(modelData.created_at).toLocaleDateString()
                                    font.pixelSize: 10
                                    color: themeManager.secondaryTextColor
                                }
                            }
                        }
                        
                        // Empty state
                        Text {
                            visible: parent.count === 0
                            anchors.centerIn: parent
                            text: "No recent sales"
                            font.pixelSize: 14
                            color: themeManager.secondaryTextColor
                        }
                    }
                }
            }
        }
        
        // Quick actions
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                Text {
                    text: "Quick Actions"
                    font.pixelSize: 18
                    font.bold: true
                    color: themeManager.textColor
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "New Sale"
                    Material.background: themeManager.primaryColor
                    Material.foreground: "white"
                    onClicked: {
                        // Navigate to sales view
                        parent.parent.parent.parent.currentView = "sales"
                    }
                }
                
                Button {
                    text: "Add Product"
                    Material.background: themeManager.accentColor
                    Material.foreground: "white"
                    onClicked: {
                        // Navigate to products view
                        parent.parent.parent.parent.currentView = "products"
                    }
                }
                
                Button {
                    text: "Add Customer"
                    Material.background: "#FF9800"
                    Material.foreground: "white"
                    onClicked: {
                        // Navigate to customers view
                        parent.parent.parent.parent.currentView = "customers"
                    }
                }
            }
        }
    }
}
