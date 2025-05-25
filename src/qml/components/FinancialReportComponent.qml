import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
// import BusinessApp 1.0  // Removed - using context properties

ScrollView {
    id: financialReportComponent
    
    property var reportData: parent.reportData || {}
    property bool isLoading: parent.isLoading || false
    
    ColumnLayout {
        width: financialReportComponent.width
        spacing: 20
        
        // Summary Cards
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            
            // Total Revenue Card
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
                        text: "Total Revenue"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.total_revenue || "0.00")
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
                            color: (reportData.revenue_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.revenue_change || 0) + "%"
                            color: (reportData.revenue_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Total Profit Card
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
                        text: "Total Profit"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.total_profit || "0.00")
                        color: "#4CAF50"
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
                            color: (reportData.profit_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.profit_change || 0) + "%"
                            color: (reportData.profit_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Total Expenses Card
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
                        text: "Total Expenses"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "$" + (reportData.total_expenses || "0.00")
                        color: "#F44336"
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
                            color: (reportData.expenses_change || 0) <= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.expenses_change || 0) + "%"
                            color: (reportData.expenses_change || 0) <= 0 ? "#4CAF50" : "#F44336"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Profit Margin Card
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
                        text: "Profit Margin"
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: (reportData.profit_margin || "0") + "%"
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
                            color: (reportData.margin_change || 0) >= 0 ? "#4CAF50" : "#F44336"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: (reportData.margin_change || 0) + "%"
                            color: (reportData.margin_change || 0) >= 0 ? "#4CAF50" : "#F44336"
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
            
            // Revenue vs Profit Chart
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
                        text: "Revenue vs Profit Trend"
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
                            id: revenueSeries
                            name: "Revenue"
                            color: themeManager.primaryColor
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.revenue_trend) {
                                    for (var i = 0; i < reportData.revenue_trend.length; i++) {
                                        append(i, reportData.revenue_trend[i])
                                    }
                                }
                            }
                        }
                        
                        LineSeries {
                            id: profitSeries
                            name: "Profit"
                            color: "#4CAF50"
                            width: 3
                            
                            Component.onCompleted: {
                                if (reportData.profit_trend) {
                                    for (var i = 0; i < reportData.profit_trend.length; i++) {
                                        append(i, reportData.profit_trend[i])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Expense Breakdown Chart
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
                        text: "Expense Breakdown"
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
                            id: expenseBreakdownSeries
                            
                            Component.onCompleted: {
                                var expenses = [
                                    { name: "Cost of Goods", value: reportData.cogs || 0, color: "#F44336" },
                                    { name: "Operating Expenses", value: reportData.operating_expenses || 0, color: "#FF9800" },
                                    { name: "Marketing", value: reportData.marketing_expenses || 0, color: "#9C27B0" },
                                    { name: "Admin & Other", value: reportData.admin_expenses || 0, color: "#607D8B" }
                                ]
                                
                                for (var i = 0; i < expenses.length; i++) {
                                    if (expenses[i].value > 0) {
                                        var slice = append(expenses[i].name, expenses[i].value)
                                        slice.color = expenses[i].color
                                        slice.labelVisible = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Financial Performance Table
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
                    text: "Monthly Financial Performance"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: monthlyPerformanceList
                        model: reportData.monthly_performance || []
                        
                        header: Rectangle {
                            width: monthlyPerformanceList.width
                            height: 40
                            color: themeManager.primaryColor
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: "Month"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "Revenue"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Expenses"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Profit"
                                    color: "white"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Margin %"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                                
                                Text {
                                    text: "Growth %"
                                    color: "white"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: monthlyPerformanceList.width
                            height: 50
                            color: index % 2 === 0 ? "transparent" : themeManager.alternateColor
                            border.color: themeManager.dividerColor
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                
                                Text {
                                    text: modelData.month || ""
                                    color: themeManager.textColor
                                    font.bold: true
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: "$" + (modelData.revenue || "0.00")
                                    color: themeManager.primaryColor
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                Text {
                                    text: "$" + (modelData.expenses || "0.00")
                                    color: "#F44336"
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                Text {
                                    text: "$" + (modelData.profit || "0.00")
                                    color: (modelData.profit || 0) >= 0 ? "#4CAF50" : "#F44336"
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                Text {
                                    text: (modelData.margin || "0") + "%"
                                    color: themeManager.textColor
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                Text {
                                    text: (modelData.growth >= 0 ? "+" : "") + (modelData.growth || "0") + "%"
                                    color: (modelData.growth || 0) >= 0 ? "#4CAF50" : "#F44336"
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                    horizontalAlignment: Text.AlignCenter
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Cash Flow Analysis
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
                    text: "Cash Flow Analysis"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Operating Cash Flow
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
                                text: "Operating Cash Flow"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.operating_cash_flow || "0.00")
                                color: (reportData.operating_cash_flow || 0) >= 0 ? "#4CAF50" : "#F44336"
                                font.pixelSize: 18
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
                    
                    // Investing Cash Flow
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
                                text: "Investing Cash Flow"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.investing_cash_flow || "0.00")
                                color: (reportData.investing_cash_flow || 0) >= 0 ? "#4CAF50" : "#F44336"
                                font.pixelSize: 18
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
                    
                    // Financing Cash Flow
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
                                text: "Financing Cash Flow"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.financing_cash_flow || "0.00")
                                color: (reportData.financing_cash_flow || 0) >= 0 ? "#4CAF50" : "#F44336"
                                font.pixelSize: 18
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
                    
                    // Net Cash Flow
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
                                text: "Net Cash Flow"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.net_cash_flow || "0.00")
                                color: (reportData.net_cash_flow || 0) >= 0 ? "#4CAF50" : "#F44336"
                                font.pixelSize: 18
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
                    
                    // Cash Balance
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
                                text: "Current Cash Balance"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.cash_balance || "0.00")
                                color: themeManager.primaryColor
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Available"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Burn Rate
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
                                text: "Monthly Burn Rate"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "$" + (reportData.burn_rate || "0.00")
                                color: "#FF9800"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Per Month"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Key Financial Ratios
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
                    text: "Key Financial Ratios"
                    color: themeManager.textColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Current Ratio
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
                                text: "Current Ratio"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.current_ratio || "0.0") + ":1"
                                color: themeManager.primaryColor
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: getRatioStatus(reportData.current_ratio, 2.0)
                                color: getRatioColor(reportData.current_ratio, 2.0)
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Quick Ratio
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
                                text: "Quick Ratio"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.quick_ratio || "0.0") + ":1"
                                color: "#4CAF50"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: getRatioStatus(reportData.quick_ratio, 1.0)
                                color: getRatioColor(reportData.quick_ratio, 1.0)
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // ROI
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
                                text: "Return on Investment"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.roi || "0") + "%"
                                color: "#FF9800"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: getRatioStatus(reportData.roi, 15)
                                color: getRatioColor(reportData.roi, 15)
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Debt to Equity
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
                                text: "Debt to Equity"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: (reportData.debt_to_equity || "0.0") + ":1"
                                color: "#9C27B0"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: getDebtRatioStatus(reportData.debt_to_equity)
                                color: getDebtRatioColor(reportData.debt_to_equity)
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Helper functions for ratio status
    function getRatioStatus(value, target) {
        if (value >= target) return "Good"
        else if (value >= target * 0.7) return "Fair"
        else return "Poor"
    }
    
    function getRatioColor(value, target) {
        if (value >= target) return "#4CAF50"
        else if (value >= target * 0.7) return "#FF9800"
        else return "#F44336"
    }
    
    function getDebtRatioStatus(value) {
        if (value <= 0.3) return "Excellent"
        else if (value <= 0.6) return "Good"
        else if (value <= 1.0) return "Fair"
        else return "High Risk"
    }
    
    function getDebtRatioColor(value) {
        if (value <= 0.3) return "#4CAF50"
        else if (value <= 0.6) return "#8BC34A"
        else if (value <= 1.0) return "#FF9800"
        else return "#F44336"
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
