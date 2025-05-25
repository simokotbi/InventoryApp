import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
// import BusinessApp 1.0  // Removed - using context properties

ScrollView {
    id: productsReportComponent
    
    property var reportData: parent.reportData || {}
    property bool isLoading: parent.isLoading || false
    
    ColumnLayout {
        width: productsReportComponent.width
        spacing: 20
        
        // Summary Cards
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            
            // Total Products Card
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
                        text: "Total Products"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.total_products || "0"
                        color: themeManager.primaryColor
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Active Products"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Low Stock Card
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
                        text: "Low Stock Items"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.low_stock_count || "0"
                        color: "#F44336"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Needs Attention"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Out of Stock Card
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
                        text: "Out of Stock"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.out_of_stock_count || "0"
                        color: "#FF5722"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Immediate Action"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Average Margin Card
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
                        text: "Avg. Profit Margin"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: (reportData.avg_profit_margin || "0") + "%"
                        color: "#4CAF50"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Across All Products"
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
            
            // Stock Distribution Chart
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
                        text: "Stock Distribution"
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
                            id: stockDistributionSeries
                            
                            Component.onCompleted: {
                                append("In Stock", reportData.in_stock_count || 0).color = "#4CAF50"
                                append("Low Stock", reportData.low_stock_count || 0).color = "#FF9800"
                                append("Out of Stock", reportData.out_of_stock_count || 0).color = "#F44336"
                            }
                        }
                    }
                }
            }
            
            // Category Performance Chart
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
                        text: "Category Performance"
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
                        
                        BarSeries {
                            id: categoryPerformanceSeries
                            
                            BarSet {
                                id: revenueBarSet
                                label: "Revenue"
                                color: themeManager.primaryColor
                            }
                            
                            BarSet {
                                id: profitBarSet
                                label: "Profit"
                                color: "#4CAF50"
                            }
                            
                            Component.onCompleted: {
                                if (reportData.category_performance) {
                                    for (var i = 0; i < reportData.category_performance.length; i++) {
                                        var category = reportData.category_performance[i]
                                        revenueBarSet.append(category.revenue || 0)
                                        profitBarSet.append(category.profit || 0)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Top Performing Products Table
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
                    text: "Top Performing Products"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: topPerformingList
                        model: reportData.top_performing_products || []
                        
                        header: Rectangle {
                            width: topPerformingList.width
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
                                    text: "Stock"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Sold"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Revenue"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Margin"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Rating"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: topPerformingList.width
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
                                
                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 24
                                    radius: 12
                                    color: getStockStatusColor(modelData.stock_level)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.stock_quantity || "0"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    function getStockStatusColor(level) {
                                        switch(level) {
                                            case "High": return "#4CAF50"
                                            case "Medium": return "#FF9800"
                                            case "Low": return "#F44336"
                                            case "Out": return "#9E9E9E"
                                            default: return themeManager.primaryColor
                                        }
                                    }
                                }
                                
                                Text {
                                    text: modelData.quantity_sold || "0"
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 80
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
                                    text: (modelData.profit_margin || "0") + "%"
                                    color: (modelData.profit_margin || 0) >= 20 ? "#4CAF50" : 
                                           (modelData.profit_margin || 0) >= 10 ? "#FF9800" : "#F44336"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Row {
                                    Layout.preferredWidth: 80
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 2
                                    
                                    Repeater {
                                        model: 5
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: index < (modelData.rating || 0) ? "#FFD700" : "#E0E0E0"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Low Stock Alert Table
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
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Low Stock Alerts"
                        color: themeManager.textColor
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 10
                        color: "#F44336"
                        
                        Text {
                            anchors.centerIn: parent
                            text: (reportData.low_stock_items && reportData.low_stock_items.length) || "0"
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
                        id: lowStockList
                        model: reportData.low_stock_items || []
                        
                        header: Rectangle {
                            width: lowStockList.width
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
                                    text: "Supplier"
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
                            width: lowStockList.width
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
                                    text: modelData.supplier || "N/A"
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 120
                                    elide: Text.ElideRight
                                }
                                
                                Button {
                                    text: "Reorder"
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 32
                                    Material.background: themeManager.accentColor
                                    Material.foreground: "white"
                                    font.pixelSize: 10
                                    onClicked: {
                                        // Handle reorder action
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Product Categories Overview
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
                    text: "Product Categories Overview"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    GridLayout {
                        columns: 3
                        columnSpacing: 16
                        rowSpacing: 16
                        
                        Repeater {
                            model: reportData.categories || []
                            
                            Rectangle {
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 100
                                color: themeManager.alternateColor
                                border.color: themeManager.dividerColor
                                border.width: 1
                                radius: 8
                                
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: modelData.name || ""
                                        color: themeManager.textColor
                                        font.bold: true
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    RowLayout {
                                        Layout.alignment: Qt.AlignHCenter
                                        spacing: 16
                                        
                                        Column {
                                            spacing: 4
                                            
                                            Text {
                                                text: "Products"
                                                color: themeManager.secondaryTextColor
                                                font.pixelSize: 10
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                            
                                            Text {
                                                text: modelData.product_count || "0"
                                                color: themeManager.primaryColor
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                        
                                        Column {
                                            spacing: 4
                                            
                                            Text {
                                                text: "Revenue"
                                                color: themeManager.secondaryTextColor
                                                font.pixelSize: 10
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                            
                                            Text {
                                                text: "$" + (modelData.revenue || "0")
                                                color: "#4CAF50"
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
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
