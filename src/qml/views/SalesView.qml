import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Item {
    id: salesView
    
    property var sales: salesHandler.sales
    property bool isLoading: salesHandler.isLoading
    property bool showNewSaleDialog: false
    property var selectedSale: null
    
    Component.onCompleted: {
        salesHandler.loadSales()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Sales"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            Button {
                text: "New Sale"
                Material.background: themeManager.primaryColor
                Material.foreground: "white"
                onClicked: salesView.showNewSaleDialog = true
            }
            
            Button {
                text: "Refresh"
                flat: true
                Material.foreground: themeManager.primaryColor
                onClicked: salesHandler.loadSales()
            }
        }
        
        // Filters and search
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search sales by customer or sale ID..."
                Material.accent: themeManager.primaryColor
                onTextChanged: salesHandler.searchSales(text)
            }
            
            ComboBox {
                id: statusFilter
                Layout.preferredWidth: 150
                model: ["All Status", "Completed", "Pending", "Cancelled"]
                Material.accent: themeManager.primaryColor
                onCurrentTextChanged: {
                    if (currentText !== "All Status") {
                        salesHandler.filterByStatus(currentText.toLowerCase())
                    } else {
                        salesHandler.clearFilters()
                    }
                }
            }
            
            ComboBox {
                id: dateFilter
                Layout.preferredWidth: 150
                model: ["All Time", "Today", "This Week", "This Month"]
                Material.accent: themeManager.primaryColor
                onCurrentTextChanged: {
                    salesHandler.filterByDate(currentText)
                }
            }
        }
        
        // Sales summary cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: themeManager.primaryColor
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        text: "$" + (salesHandler.todayTotal || 0).toFixed(2)
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Today's Sales"
                        color: "white"
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: themeManager.accentColor
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        text: (salesHandler.todayCount || 0).toString()
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Sales Today"
                        color: "white"
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#FF9800"
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        text: "$" + (salesHandler.averageTotal || 0).toFixed(2)
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Average Sale"
                        color: "white"
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
        
        // Sales table
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
                spacing: 0
                
                // Table header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Qt.lighter(themeManager.primaryColor, 1.8)
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 16
                        
                        Text {
                            text: "Sale ID"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Customer"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 200
                        }
                        
                        Text {
                            text: "Items"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Total"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                        
                        Text {
                            text: "Status"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                        
                        Text {
                            text: "Date"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 120
                        }
                        
                        Text {
                            text: "Actions"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // Sales list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    model: sales
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.02)
                        border.color: themeManager.dividerColor
                        border.width: 1
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = Qt.rgba(0, 0, 0, 0.05)
                            onExited: parent.color = index % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.02)
                            onDoubleClicked: {
                                salesView.selectedSale = modelData
                                saleDetailsDialog.open()
                            }
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 16
                            
                            // Sale ID
                            Text {
                                Layout.preferredWidth: 80
                                text: "#" + (modelData.id || "N/A")
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            // Customer
                            Text {
                                Layout.preferredWidth: 200
                                text: modelData.customer_name || "Walk-in Customer"
                                color: themeManager.textColor
                                elide: Text.ElideRight
                            }
                            
                            // Items count
                            Text {
                                Layout.preferredWidth: 80
                                text: (modelData.items_count || 0).toString()
                                color: themeManager.textColor
                            }
                            
                            // Total
                            Text {
                                Layout.preferredWidth: 100
                                text: "$" + (modelData.total || 0).toFixed(2)
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            // Status
                            Rectangle {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 24
                                color: getStatusColor(modelData.status)
                                radius: 12
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: (modelData.status || "pending").charAt(0).toUpperCase() + (modelData.status || "pending").slice(1)
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            // Date
                            Text {
                                Layout.preferredWidth: 120
                                text: new Date(modelData.created_at || Date.now()).toLocaleDateString()
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                            }
                            
                            // Actions
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Button {
                                    text: "View"
                                    flat: true
                                    Material.foreground: themeManager.accentColor
                                    onClicked: {
                                        salesView.selectedSale = modelData
                                        saleDetailsDialog.open()
                                    }
                                }
                                
                                Button {
                                    text: "Print"
                                    flat: true
                                    Material.foreground: themeManager.primaryColor
                                    onClicked: salesHandler.printReceipt(modelData.id)
                                }
                                
                                Button {
                                    text: "Void"
                                    flat: true
                                    Material.foreground: themeManager.errorColor
                                    visible: modelData.status === "completed"
                                    onClicked: {
                                        voidConfirmDialog.saleToVoid = modelData
                                        voidConfirmDialog.open()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0 && !salesView.isLoading
                        anchors.centerIn: parent
                        text: "No sales found"
                        font.pixelSize: 16
                        color: themeManager.secondaryTextColor
                    }
                    
                    // Loading indicator
                    BusyIndicator {
                        visible: salesView.isLoading
                        anchors.centerIn: parent
                        Material.accent: themeManager.primaryColor
                        running: true
                    }
                }
            }
        }
    }
    
    // New Sale Dialog
    NewSaleDialog {
        id: newSaleDialog
        visible: salesView.showNewSaleDialog
        
        onAccepted: {
            salesHandler.createSale(saleData)
            salesView.showNewSaleDialog = false
        }
        
        onRejected: {
            salesView.showNewSaleDialog = false
        }
    }
    
    // Sale Details Dialog
    SaleDetailsDialog {
        id: saleDetailsDialog
        sale: salesView.selectedSale
    }
    
    // Void confirmation dialog
    MessagePopup {
        id: voidConfirmDialog
        title: "Void Sale"
        message: "Are you sure you want to void this sale? This action cannot be undone and will restore inventory."
        type: "warning"
        
        property var saleToVoid: null
        
        onAccepted: {
            if (saleToVoid) {
                salesHandler.voidSale(saleToVoid.id)
                saleToVoid = null
            }
        }
    }
    
    function getStatusColor(status) {
        switch(status) {
            case "completed": return "#4CAF50"
            case "pending": return "#FF9800"
            case "cancelled": return themeManager.errorColor
            default: return themeManager.secondaryTextColor
        }
    }
}
