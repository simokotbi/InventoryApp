import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
// import BusinessApp 1.0  // Removed - using context properties

ScrollView {
    id: customersReportComponent
    
    property var reportData: parent.reportData || {}
    property bool isLoading: parent.isLoading || false
    
    ColumnLayout {
        width: customersReportComponent.width
        spacing: 20
        
        // Summary Cards
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            
            // Total Customers Card
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
                        text: "Total Customers"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.total_customers || "0"
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
                            color: (reportData.customer_growth || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.customer_growth || 0) + "%"
                            color: (reportData.customer_growth || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // New Customers Card
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
                        text: "New Customers"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.new_customers || "0"
                        color: "#4CAF50"
                        font.pixelSize: 24
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
            
            // Active Customers Card
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
                        text: "Active Customers"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: reportData.active_customers || "0"
                        color: "#FF9800"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Last 30 Days"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Customer Lifetime Value Card
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
                        text: "Avg. Lifetime Value"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.avg_lifetime_value || "0.00")
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
                            color: (reportData.clv_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.clv_change || 0) + "%"
                            color: (reportData.clv_change || 0) >= 0 ? "#4CAF50" : "#F44336"
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
            
            // Customer Acquisition Chart
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
                        text: "Customer Acquisition Trend"
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
                            id: acquisitionSeries
                            name: "New Customers"
                            color: themeManager.primaryColor
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.acquisition_trend) {
                                    for (var i = 0; i < reportData.acquisition_trend.length; i++) {
                                        append(i, reportData.acquisition_trend[i])
                                    }
                                }
                            }
                        }
                        
                        LineSeries {
                            id: retentionSeries
                            name: "Retained Customers"
                            color: "#4CAF50"
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.retention_trend) {
                                    for (var i = 0; i < reportData.retention_trend.length; i++) {
                                        append(i, reportData.retention_trend[i])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Customer Segmentation Chart
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
                        text: "Customer Segmentation"
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
                            id: segmentationSeries
                            
                            Component.onCompleted: {
                                var segments = [
                                    { name: "VIP Customers", value: reportData.vip_customers || 0, color: "#FFD700" },
                                    { name: "Regular Customers", value: reportData.regular_customers || 0, color: themeManager.primaryColor },
                                    { name: "New Customers", value: reportData.new_customers || 0, color: "#4CAF50" },
                                    { name: "Inactive Customers", value: reportData.inactive_customers || 0, color: "#9E9E9E" }
                                ]
                                
                                for (var i = 0; i < segments.length; i++) {
                                    var slice = append(segments[i].name, segments[i].value)
                                    slice.color = segments[i].color
                                    slice.labelVisible = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Top Customers Table
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
                    text: "Top Customers by Revenue"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: topCustomersList
                        model: reportData.top_customers || []
                        
                        header: Rectangle {
                            width: topCustomersList.width
                            height: 40
                            color: themeManager.primaryColor
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: "Customer"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Orders"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Total Spent"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                }
                                
                                Text {
                                    text: "Last Order"
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
                            width: topCustomersList.width
                            height: 60
                            color: index % 2 === 0 ? "transparent" : themeManager.alternateColor
                            border.color: themeManager.dividerColor
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Column {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    Text {
                                        text: modelData.name || ""
                                        color: themeManager.textColor
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        text: modelData.email || ""
                                        color: themeManager.secondaryTextColor
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                }
                                
                                Text {
                                    text: modelData.order_count || "0"
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: "$" + (modelData.total_spent || "0.00")
                                    color: themeManager.primaryColor
                                    font.bold: true
                                    Layout.preferredWidth: 120
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                Text {
                                    text: modelData.last_order_date || "N/A"
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                    Layout.preferredWidth: 100
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 24
                                    radius: 12
                                    color: getCustomerStatusColor(modelData.status)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.status || "Regular"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    function getCustomerStatusColor(status) {
                                        switch(status) {
                                            case "VIP": return "#FFD700"
                                            case "Regular": return themeManager.primaryColor
                                            case "New": return "#4CAF50"
                                            case "Inactive": return "#9E9E9E"
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
        
        // Customer Activity Analysis
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
                    text: "Customer Activity Analysis"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Purchase Frequency
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "Avg. Purchase Frequency"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.avg_purchase_frequency || "0") + " days"
                                color: themeManager.primaryColor
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Between Orders"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Customer Retention Rate
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "Retention Rate"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.retention_rate || "0") + "%"
                                color: "#4CAF50"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "90-Day Cohort"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Churn Rate
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "Churn Rate"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.churn_rate || "0") + "%"
                                color: "#F44336"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Monthly Rate"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Customer Feedback & Reviews
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
                    text: "Customer Satisfaction"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    // Average Rating
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 120
                        color: themeManager.alternateColor
                        border.color: themeManager.dividerColor
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "Average Rating"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 4
                                
                                Text {
                                    text: (reportData.avg_rating || "0.0")
                                    color: "#FFD700"
                                    font.pixelSize: 24
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "/ 5.0"
                                    color: themeManager.secondaryTextColor
                                    font.pixelSize: 16
                                }
                            }
                            
                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 2
                                
                                Repeater {
                                    model: 5
                                    Rectangle {
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: index < Math.floor(reportData.avg_rating || 0) ? "#FFD700" : "#E0E0E0"
                                    }
                                }
                            }
                        }
                    }
                    
                    // Reviews Distribution
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Reviews Distribution"
                            color: themeManager.textColor
                            font.bold: true
                        }
                        
                        Repeater {
                            model: [
                                { stars: 5, count: reportData.five_star_reviews || 0 },
                                { stars: 4, count: reportData.four_star_reviews || 0 },
                                { stars: 3, count: reportData.three_star_reviews || 0 },
                                { stars: 2, count: reportData.two_star_reviews || 0 },
                                { stars: 1, count: reportData.one_star_reviews || 0 }
                            ]
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Text {
                                    text: modelData.stars + " ★"
                                    color: "#FFD700"
                                    font.bold: true
                                    Layout.preferredWidth: 40
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    color: themeManager.dividerColor
                                    radius: 10
                                    
                                    Rectangle {
                                        width: parent.width * (modelData.count / Math.max(1, reportData.total_reviews || 1))
                                        height: parent.height
                                        color: "#FFD700"
                                        radius: 10
                                    }
                                }
                                
                                Text {
                                    text: modelData.count
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 30
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
