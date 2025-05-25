import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
// import BusinessApp 1.0  // Removed - using context properties

ScrollView {
    id: inventoryReportComponent
    
    property var reportData: parent.reportData || {}
    property bool isLoading: parent.isLoading || false
    
    ColumnLayout {
        width: inventoryReportComponent.width
        spacing: 20
        
        // Summary Cards
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            
            // Total Inventory Value Card
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
                        text: "Total Inventory Value"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.total_inventory_value || "0.00")
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
                            color: (reportData.inventory_value_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.inventory_value_change || 0) + "%"
                            color: (reportData.inventory_value_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Total Items Card
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
                        text: "Total Items"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.total_items || "0"
                        color: "#4CAF50"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "In Stock"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Low Stock Alerts Card
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
                        text: "Low Stock Alerts"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.low_stock_alerts || "0"
                        color: "#FF9800"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Requires Attention"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Inventory Turnover Card
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
                        text: "Inventory Turnover"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: (reportData.inventory_turnover || "0.0") + "x"
                        color: "#9C27B0"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Times Per Year"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
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
            
            // Inventory Movement Chart
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
                        text: "Inventory Movement Trend"
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
                            id: stockInSeries
                            name: "Stock In"
                            color: "#4CAF50"
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.stock_in_trend) {
                                    for (var i = 0; i < reportData.stock_in_trend.length; i++) {
                                        append(i, reportData.stock_in_trend[i])
                                    }
                                }
                            }
                        }
                        
                        LineSeries {
                            id: stockOutSeries
                            name: "Stock Out"
                            color: "#F44336"
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.stock_out_trend) {
                                    for (var i = 0; i < reportData.stock_out_trend.length; i++) {
                                        append(i, reportData.stock_out_trend[i])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Stock Status Distribution Chart
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
                        text: "Stock Status Distribution"
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
                            id: stockStatusSeries
                            
                            Component.onCompleted: {
                                append("In Stock", reportData.in_stock_count || 0).color = "#4CAF50"
                                append("Low Stock", reportData.low_stock_count || 0).color = "#FF9800"
                                append("Out of Stock", reportData.out_of_stock_count || 0).color = "#F44336"
                                append("Excess Stock", reportData.excess_stock_count || 0).color = "#607D8B"
                            }
                        }
                    }
                }
            }
        }
        
        // Stock Movement History Table
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
                        text: "Recent Stock Movements"
                        color: themeManager.textColor
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    ComboBox {
                        Layout.preferredWidth: 150
                        model: ["All Types", "Stock In", "Stock Out", "Adjustments", "Returns"]
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: movementsList
                        model: reportData.recent_movements || []
                        
                        header: Rectangle {
                            width: movementsList.width
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
                                    text: "Product"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Type"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Quantity"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Previous"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "New Stock"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Reason"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: movementsList.width
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
                                    font.pixelSize: 12
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: modelData.product_name || ""
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 24
                                    radius: 12
                                    color: getMovementTypeColor(modelData.movement_type)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.movement_type || ""
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    function getMovementTypeColor(type) {
                                        switch(type) {
                                            case "Stock In": return "#4CAF50"
                                            case "Stock Out": return "#F44336"
                                            case "Adjustment": return "#FF9800"
                                            case "Return": return "#2196F3"
                                            default: return themeManager.primaryColor
                                        }
                                    }
                                }
                                
                                Text {
                                    text: (modelData.movement_type === "Stock Out" ? "-" : "+") + (modelData.quantity || "0")
                                    color: modelData.movement_type === "Stock Out" ? "#F44336" : "#4CAF50"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: modelData.previous_stock || "0"
                                    color: themeManager.secondaryTextColor
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: modelData.new_stock || "0"
                                    color: themeManager.textColor
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: modelData.reason || ""
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                    Layout.preferredWidth: 120
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Critical Stock Levels Table
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 350
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
                        text: "Critical Stock Levels"
                        color: themeManager.textColor
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        radius: 12
                        color: "#F44336"
                        
                        Text {
                            anchors.centerIn: parent
                            text: (reportData.critical_stock_items && reportData.critical_stock_items.length) || "0"
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: criticalStockList
                        model: reportData.critical_stock_items || []
                        
                        header: Rectangle {
                            width: criticalStockList.width
                            height: 40
                            color: "#F44336"
                            
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
                                    text: "Current Stock"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                }
                                
                                Text {
                                    text: "Min. Level"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Days Left"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Suggested Order"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                }
                                
                                Text {
                                    text: "Action"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: criticalStockList.width
                            height: 50
                            color: index % 2 === 0 ? "transparent" : themeManager.alternateColor
                            border.color: themeManager.dividerColor
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: modelData.product_name || ""
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: modelData.current_stock || "0"
                                    color: "#F44336"
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: modelData.min_level || "0"
                                    color: themeManager.secondaryTextColor
                                    Layout.preferredWidth: 100
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: modelData.days_left || "0"
                                    color: (modelData.days_left || 0) <= 7 ? "#F44336" : "#FF9800"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: modelData.suggested_order || "0"
                                    color: themeManager.primaryColor
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Button {
                                    text: "Order Now"
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 32
                                    Material.background: themeManager.accentColor
                                    Material.foreground: "white"
                                    font.pixelSize: 10
                                    onClicked: {
                                        // Handle order action
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Inventory Performance Metrics
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                Text {
                    text: "Inventory Performance Metrics"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Inventory Accuracy
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                text: "Inventory Accuracy"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.inventory_accuracy || "0") + "%"
                                color: "#4CAF50"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "System vs Physical"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Stockout Rate
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                text: "Stockout Rate"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.stockout_rate || "0") + "%"
                                color: "#F44336"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "This Period"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Days Sales Outstanding
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                text: "Days Sales in Inventory"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.days_sales_inventory || "0") + " days"
                                color: "#FF9800"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Average"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Carrying Cost
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                text: "Carrying Cost"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.carrying_cost || "0")
                                color: "#9C27B0"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Monthly"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
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
