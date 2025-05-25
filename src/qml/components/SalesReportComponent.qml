import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
// import BusinessApp 1.0  // Removed - using context properties

ScrollView {
    id: salesReportComponent
    
    property var reportData: parent.reportData || {}
    property bool isLoading: parent.isLoading || false
    
    ColumnLayout {
        width: salesReportComponent.width
        spacing: 20
        
        // Summary Cards
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            
            // Total Sales Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "Total Sales"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.total_sales || "0.00")
                        color: themeManager.primaryColor
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: (reportData.sales_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.sales_change || 0) + "%"
                            color: (reportData.sales_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Total Orders Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "Total Orders"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.total_orders || "0"
                        color: themeManager.accentColor
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: (reportData.orders_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.orders_change || 0) + "%"
                            color: (reportData.orders_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Average Order Value Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "Avg. Order Value"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.avg_order_value || "0.00")
                        color: "#FF9800"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: (reportData.aov_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.aov_change || 0) + "%"
                            color: (reportData.aov_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Conversion Rate Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "Conversion Rate"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: (reportData.conversion_rate || "0") + "%"
                        color: "#9C27B0"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: (reportData.conversion_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.conversion_change || 0) + "%"
                            color: (reportData.conversion_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
        }
        
        // Charts Section
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 16
            rowSpacing: 16
            
            // Sales Trend Chart
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Text {
                        text: "Sales Trend"
                        color: themeManager.textColor
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    ChartView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        backgroundColor: "transparent"
                        plotAreaColor: "transparent"
                        
                        LineSeries {
                            id: salesTrendSeries
                            name: "Sales"
                            color: themeManager.primaryColor
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.sales_trend) {
                                    for (var i = 0; i < reportData.sales_trend.length; i++) {
                                        append(i, reportData.sales_trend[i])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Sales by Category Chart
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Text {
                        text: "Sales by Category"
                        color: themeManager.textColor
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    ChartView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        backgroundColor: "transparent"
                        plotAreaColor: "transparent"
                        
                        PieSeries {
                            id: categoryPieSeries
                            
                            Component.onCompleted: {
                                if (reportData.sales_by_category) {
                                    var colors = ["#2196F3", "#4CAF50", "#FF9800", "#F44336", "#9C27B0", "#607D8B"]
                                    for (var i = 0; i < reportData.sales_by_category.length; i++) {
                                        var slice = append(reportData.sales_by_category[i].category, reportData.sales_by_category[i].value)
                                        slice.color = colors[i % colors.length]
                                        slice.labelVisible = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Top Products Table
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 400
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                Text {
                    text: "Top Selling Products"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: topProductsList
                        model: reportData.top_products || []
                        
                        header: Rectangle {
                            width: topProductsList.width
                            height: 40
                            color: themeManager.primaryColor
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: "Product"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Quantity Sold"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                }
                                
                                Text {
                                    text: "Revenue"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Profit"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: topProductsList.width
                            height: 50
                            color: index % 2 === 0 ? "transparent" : themeManager.alternateColor
                            border.color: themeManager.dividerColor
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: modelData.name || ""
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: modelData.quantity_sold || "0"
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 120
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: "$" + (modelData.revenue || "0.00")
                                    color: themeManager.primaryColor
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                Text {
                                    text: "$" + (modelData.profit || "0.00")
                                    color: (modelData.profit || 0) >= 0 ? "#4CAF50" : "#F44336"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Recent Sales Table
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 400
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Recent Sales"
                        color: themeManager.textColor
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "View All"
                        flat: true
                        Material.foreground: themeManager.primaryColor
                        onClicked: {
                            // Navigate to full sales view
                        }
                    }
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: recentSalesList
                        model: reportData.recent_sales || []
                        
                        header: Rectangle {
                            width: recentSalesList.width
                            height: 40
                            color: themeManager.primaryColor
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: "Date"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Customer"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Items"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: "Total"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Status"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: recentSalesList.width
                            height: 50
                            color: index % 2 === 0 ? "transparent" : themeManager.alternateColor
                            border.color: themeManager.dividerColor
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: modelData.date || ""
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 100
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: modelData.customer || "Walk-in"
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: modelData.item_count || "0"
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 60
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: "$" + (modelData.total || "0.00")
                                    color: themeManager.textColor
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 24
                                    radius: 12
                                    color: getStatusColor(modelData.status)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.status || "Completed"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    function getStatusColor(status) {
                                        switch(status) {
                                            case "Completed": return "#4CAF50"
                                            case "Pending": return "#FF9800"
                                            case "Cancelled": return "#F44336"
                                            case "Refunded": return "#607D8B"
                                            default: return themeManager.primaryColor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Loading overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(themeManager.backgroundColor.r, themeManager.backgroundColor.g, themeManager.backgroundColor.b, 0.8)
        visible: isLoading
        
        BusyIndicator {
            anchors.centerIn: parent
            running: isLoading
            Material.accent: themeManager.primaryColor
        }
    }
}
