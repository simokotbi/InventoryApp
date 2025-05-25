import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Item {
    id: reportsView
    
    property string selectedReportType: "sales"
    property var reportData: reportsHandler.reportData
    property bool isLoading: reportsHandler.isLoading
    
    Component.onCompleted: {
        loadReport()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Reports & Analytics"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            Button {
                text: "Export"
                Material.background: themeManager.accentColor
                Material.foreground: "white"
                onClicked: exportReport()
            }
            
            Button {
                text: "Refresh"
                flat: true
                Material.foreground: themeManager.primaryColor
                onClicked: loadReport()
            }
        }
        
        // Report type and date range selection
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                Text {
                    text: "Report Type:"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                ComboBox {
                    id: reportTypeCombo
                    Layout.preferredWidth: 200
                    model: [
                        { text: "Sales Report", value: "sales" },
                        { text: "Product Performance", value: "products" },
                        { text: "Customer Analytics", value: "customers" },
                        { text: "Inventory Report", value: "inventory" },
                        { text: "Financial Summary", value: "financial" }
                    ]
                    textRole: "text"
                    valueRole: "value"
                    Material.accent: themeManager.primaryColor
                    
                    onCurrentValueChanged: {
                        reportsView.selectedReportType = currentValue
                        loadReport()
                    }
                }
                
                Rectangle {
                    width: 1
                    height: 40
                    color: themeManager.dividerColor
                }
                
                Text {
                    text: "Date Range:"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                ComboBox {
                    id: dateRangeCombo
                    Layout.preferredWidth: 150
                    model: ["Today", "This Week", "This Month", "Last Month", "This Quarter", "This Year", "Custom"]
                    Material.accent: themeManager.primaryColor
                    
                    onCurrentTextChanged: {
                        if (currentText === "Custom") {
                            customDateDialog.open()
                        } else {
                            loadReport()
                        }
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                // Quick stats
                Text {
                    text: "Total Records: " + (reportData ? reportData.total_records || 0 : 0)
                    color: themeManager.secondaryTextColor
                    font.pixelSize: 12
                }
            }
        }
        
        // Report content based on type
        StackView {
            id: reportStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            initialItem: getSalesReportComponent()
            
            Connections {
                target: reportsView
                function onSelectedReportTypeChanged() {
                    updateReportView()
                }
            }
            
            function updateReportView() {
                var component
                switch(reportsView.selectedReportType) {
                    case "sales":
                        component = getSalesReportComponent()
                        break
                    case "products":
                        component = getProductsReportComponent()
                        break
                    case "customers":
                        component = getCustomersReportComponent()
                        break
                    case "inventory":
                        component = getInventoryReportComponent()
                        break
                    case "financial":
                        component = getFinancialReportComponent()
                        break
                    default:
                        component = getSalesReportComponent()
                }
                
                reportStack.replace(component)
            }
        }
    }
    
    // Sales Report Component
    function getSalesReportComponent() {
        return Qt.createComponent("../components/SalesReportComponent.qml")
    }
    
    // Products Report Component  
    function getProductsReportComponent() {
        return Qt.createComponent("../components/ProductsReportComponent.qml")
    }
    
    // Customers Report Component
    function getCustomersReportComponent() {
        return Qt.createComponent("../components/CustomersReportComponent.qml")
    }
    
    // Inventory Report Component
    function getInventoryReportComponent() {
        return Qt.createComponent("../components/InventoryReportComponent.qml")
    }
    
    // Financial Report Component
    function getFinancialReportComponent() {
        return Qt.createComponent("../components/FinancialReportComponent.qml")
    }
    
    // Custom Date Range Dialog
    Dialog {
        id: customDateDialog
        title: "Custom Date Range"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 200
        
        Material.accent: themeManager.primaryColor
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Start Date"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: startDateField
                        Layout.fillWidth: true
                        placeholderText: "YYYY-MM-DD"
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "End Date"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: endDateField
                        Layout.fillWidth: true
                        placeholderText: "YYYY-MM-DD"
                        Material.accent: themeManager.primaryColor
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
        
        standardButtons: Dialog.Ok | Dialog.Cancel
        
        onAccepted: {
            loadReport(startDateField.text, endDateField.text)
        }
    }
    
    // Simple fallback report component when others aren't available
    Component {
        id: fallbackReportComponent
        
        Rectangle {
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16
                
                // Loading indicator
                BusyIndicator {
                    visible: reportsView.isLoading
                    Layout.alignment: Qt.AlignHCenter
                    Material.accent: themeManager.primaryColor
                    running: true
                }
                
                // Report content
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !reportsView.isLoading
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 16
                        
                        Text {
                            text: getReportTitle()
                            font.pixelSize: 20
                            font.bold: true
                            color: themeManager.textColor
                        }
                        
                        // Summary cards
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 16
                            rowSpacing: 16
                            
                            Repeater {
                                model: getReportSummary()
                                
                                StatsCard {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    title: modelData.title
                                    value: modelData.value
                                    icon: modelData.icon
                                    color: modelData.color
                                }
                            }
                        }
                        
                        // Data table placeholder
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            color: "transparent"
                            border.color: themeManager.dividerColor
                            border.width: 1
                            radius: 8
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📊 Detailed report data will be displayed here"
                                font.pixelSize: 16
                                color: themeManager.secondaryTextColor
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Helper functions
    function loadReport(startDate, endDate) {
        var dateRange = startDate && endDate ? "custom" : dateRangeCombo.currentText.toLowerCase().replace(" ", "_")
        reportsHandler.loadReport(selectedReportType, dateRange, startDate, endDate)
    }
    
    function exportReport() {
        reportsHandler.exportReport(selectedReportType, "pdf")
    }
    
    function getReportTitle() {
        switch(selectedReportType) {
            case "sales": return "Sales Report"
            case "products": return "Product Performance Report"
            case "customers": return "Customer Analytics Report"
            case "inventory": return "Inventory Report"
            case "financial": return "Financial Summary Report"
            default: return "Report"
        }
    }
    
    function getReportSummary() {
        if (!reportData) return []
        
        switch(selectedReportType) {
            case "sales":
                return [
                    { title: "Total Sales", value: "$" + (reportData.total_sales || 0).toFixed(2), icon: "💰", color: themeManager.primaryColor },
                    { title: "Number of Sales", value: (reportData.sales_count || 0).toString(), icon: "🛒", color: themeManager.accentColor },
                    { title: "Average Sale", value: "$" + (reportData.average_sale || 0).toFixed(2), icon: "📊", color: "#FF9800" }
                ]
            case "products":
                return [
                    { title: "Top Product", value: reportData.top_product || "N/A", icon: "🏆", color: themeManager.primaryColor },
                    { title: "Products Sold", value: (reportData.products_sold || 0).toString(), icon: "📦", color: themeManager.accentColor },
                    { title: "Revenue", value: "$" + (reportData.product_revenue || 0).toFixed(2), icon: "💵", color: "#4CAF50" }
                ]
            default:
                return [
                    { title: "Total Records", value: (reportData.total_records || 0).toString(), icon: "📋", color: themeManager.primaryColor },
                    { title: "Period", value: dateRangeCombo.currentText, icon: "📅", color: themeManager.accentColor },
                    { title: "Generated", value: new Date().toLocaleDateString(), icon: "🕒", color: "#FF9800" }
                ]
        }
    }
}
