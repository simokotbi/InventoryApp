import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: saleDetailsDialog
    
    property var sale: null
    property var saleItems: salesHandler.saleItems || []
    
    title: "Sale Details - #" + (sale ? sale.id || "N/A" : "N/A")
    modal: true
    anchors.centerIn: parent
    width: 800
    height: 700
    
    Material.accent: themeManager.primaryColor
    
    onOpened: {
        if (sale) {
            salesHandler.loadSaleItems(sale.id)
        }
    }
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            // Sale header info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // Sale icon and basic info
                    ColumnLayout {
                        spacing: 8
                        
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            color: getStatusColor()
                            radius: 30
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🛒"
                                font.pixelSize: 24
                            }
                        }
                        
                        Text {
                            text: "#" + (sale ? sale.id || "N/A" : "N/A")
                            font.bold: true
                            color: themeManager.textColor
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Sale details
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Customer:"
                                    font.bold: true
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: sale ? (sale.customer_name || "Walk-in Customer") : "N/A"
                                    color: themeManager.secondaryTextColor
                                    font.pixelSize: 12
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Date:"
                                    font.bold: true
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: sale ? new Date(sale.created_at).toLocaleString() : "N/A"
                                    color: themeManager.secondaryTextColor
                                    font.pixelSize: 12
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Status:"
                                    font.bold: true
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 20
                                    color: getStatusColor()
                                    radius: 10
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: sale ? (sale.status || "pending").charAt(0).toUpperCase() + (sale.status || "pending").slice(1) : "N/A"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Cashier:"
                                    font.bold: true
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: sale ? (sale.cashier_name || "N/A") : "N/A"
                                    color: themeManager.secondaryTextColor
                                    font.pixelSize: 12
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Payment Method:"
                                    font.bold: true
                                    color: themeManager.textColor
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: sale ? (sale.payment_method || "Cash") : "N/A"
                                    color: themeManager.secondaryTextColor
                                    font.pixelSize: 12
                                }
                            }
                            
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    // Total amount
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 80
                        color: themeManager.primaryColor
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            Text {
                                text: "$" + (sale ? (sale.total || 0).toFixed(2) : "0.00")
                                color: "white"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Total"
                                color: "white"
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
            
            // Sale items
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
                    spacing: 8
                    
                    Text {
                        text: "Sale Items"
                        font.pixelSize: 16
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    // Table header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        color: Qt.lighter(themeManager.primaryColor, 1.8)
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 16
                            
                            Text {
                                text: "Product"
                                font.bold: true
                                color: themeManager.textColor
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "SKU"
                                font.bold: true
                                color: themeManager.textColor
                                Layout.preferredWidth: 100
                            }
                            
                            Text {
                                text: "Qty"
                                font.bold: true
                                color: themeManager.textColor
                                Layout.preferredWidth: 50
                            }
                            
                            Text {
                                text: "Price"
                                font.bold: true
                                color: themeManager.textColor
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: "Discount"
                                font.bold: true
                                color: themeManager.textColor
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: "Total"
                                font.bold: true
                                color: themeManager.textColor
                                Layout.preferredWidth: 80
                            }
                        }
                    }
                    
                    // Items list
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        model: saleItems
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.02)
                            border.color: themeManager.dividerColor
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = Qt.rgba(0, 0, 0, 0.05)
                                onExited: parent.color = index % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.02)
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 16
                                
                                // Product name
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.product_name || "N/A"
                                        color: themeManager.textColor
                                        font.bold: true
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: modelData.product_description || ""
                                        color: themeManager.secondaryTextColor
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                // SKU
                                Text {
                                    Layout.preferredWidth: 100
                                    text: modelData.product_sku || "N/A"
                                    color: themeManager.secondaryTextColor
                                    elide: Text.ElideRight
                                    font.pixelSize: 11
                                }
                                
                                // Quantity
                                Text {
                                    Layout.preferredWidth: 50
                                    text: (modelData.quantity || 0).toString()
                                    color: themeManager.textColor
                                    font.bold: true
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                // Unit price
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "$" + (modelData.unit_price || 0).toFixed(2)
                                    color: themeManager.textColor
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                // Discount
                                Text {
                                    Layout.preferredWidth: 80
                                    text: modelData.discount ? "-$" + (modelData.discount || 0).toFixed(2) : "-"
                                    color: modelData.discount ? themeManager.errorColor : themeManager.secondaryTextColor
                                    horizontalAlignment: Text.AlignRight
                                    font.pixelSize: 11
                                }
                                
                                // Line total
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "$" + (modelData.line_total || 0).toFixed(2)
                                    color: themeManager.textColor
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                        
                        // Empty state
                        Text {
                            visible: parent.count === 0
                            anchors.centerIn: parent
                            text: "No items found"
                            font.pixelSize: 14
                            color: themeManager.secondaryTextColor
                        }
                    }
                }
            }
            
            // Sale totals breakdown
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // Notes
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Notes"
                            font.bold: true
                            color: themeManager.textColor
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Qt.rgba(0, 0, 0, 0.02)
                            border.color: themeManager.dividerColor
                            border.width: 1
                            radius: 4
                            
                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 8
                                
                                Text {
                                    text: sale ? (sale.notes || "No notes") : "No notes"
                                    color: sale && sale.notes ? themeManager.textColor : themeManager.secondaryTextColor
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }
                        }
                    }
                    
                    // Totals breakdown
                    ColumnLayout {
                        Layout.preferredWidth: 200
                        spacing: 8
                        
                        Text {
                            text: "Totals Breakdown"
                            font.bold: true
                            color: themeManager.textColor
                        }
                        
                        ColumnLayout {
                            spacing: 4
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Subtotal:"
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "$" + (sale ? (sale.subtotal || 0).toFixed(2) : "0.00")
                                    color: themeManager.textColor
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Discount:"
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "-$" + (sale ? (sale.discount || 0).toFixed(2) : "0.00")
                                    color: themeManager.errorColor
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Tax:"
                                    color: themeManager.textColor
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "$" + (sale ? (sale.tax || 0).toFixed(2) : "0.00")
                                    color: themeManager.textColor
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: themeManager.dividerColor
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Total:"
                                    color: themeManager.textColor
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "$" + (sale ? (sale.total || 0).toFixed(2) : "0.00")
                                    color: themeManager.primaryColor
                                    font.bold: true
                                    font.pixelSize: 16
                                }
                            }
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    // Custom footer with action buttons
    footer: RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 8
        
        Button {
            text: "Print Receipt"
            flat: true
            Material.foreground: themeManager.primaryColor
            onClicked: {
                if (sale) {
                    salesHandler.printReceipt(sale.id)
                }
            }
        }
        
        Button {
            text: "Email Receipt"
            flat: true
            Material.foreground: themeManager.accentColor
            visible: sale && sale.customer_email
            onClicked: {
                if (sale) {
                    salesHandler.emailReceipt(sale.id)
                }
            }
        }
        
        Button {
            text: "Refund"
            flat: true
            Material.foreground: themeManager.errorColor
            visible: sale && sale.status === "completed"
            onClicked: {
                refundConfirmDialog.open()
            }
        }
        
        Button {
            text: "Close"
            Material.background: themeManager.primaryColor
            Material.foreground: "white"
            onClicked: saleDetailsDialog.close()
        }
    }
    
    // Helper functions
    function getStatusColor() {
        if (!sale) return themeManager.secondaryTextColor
        
        switch(sale.status) {
            case "completed": return "#4CAF50"
            case "pending": return "#FF9800"
            case "cancelled": return themeManager.errorColor
            case "refunded": return "#9C27B0"
            default: return themeManager.secondaryTextColor
        }
    }
    
    // Refund confirmation dialog
    MessagePopup {
        id: refundConfirmDialog
        title: "Process Refund"
        message: "Are you sure you want to process a refund for this sale? This action cannot be undone and will restore inventory."
        type: "warning"
        
        onAccepted: {
            if (sale) {
                salesHandler.processRefund(sale.id)
                saleDetailsDialog.close()
            }
        }
    }
}
