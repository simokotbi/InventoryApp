import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Item {
    id: inventoryView
    
    property var inventory: inventoryHandler.inventory
    property bool isLoading: inventoryHandler.isLoading
    property bool showMovementDialog: false
    property var selectedItem: null
    
    Component.onCompleted: {
        inventoryHandler.loadInventory()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Inventory Management"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            Button {
                text: "Stock Movement"
                Material.background: themeManager.primaryColor
                Material.foreground: "white"
                onClicked: inventoryView.showMovementDialog = true
            }
            
            Button {
                text: "Refresh"
                flat: true
                Material.foreground: themeManager.primaryColor
                onClicked: inventoryHandler.loadInventory()
            }
        }
        
        // Summary cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                title: "Total Products"
                value: inventory ? inventory.length.toString() : "0"
                icon: "📦"
                color: themeManager.primaryColor
            }
            
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                title: "Low Stock Items"
                value: getLowStockCount().toString()
                icon: "⚠️"
                color: themeManager.errorColor
                isWarning: true
            }
            
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                title: "Out of Stock"
                value: getOutOfStockCount().toString()
                icon: "🚫"
                color: "#FF5722"
                isWarning: true
            }
            
            StatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                title: "Total Value"
                value: "$" + getTotalValue().toFixed(2)
                icon: "💰"
                color: themeManager.accentColor
            }
        }
        
        // Filters
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search products..."
                Material.accent: themeManager.primaryColor
                onTextChanged: inventoryHandler.searchInventory(text)
            }
            
            ComboBox {
                id: stockFilter
                Layout.preferredWidth: 150
                model: ["All Items", "In Stock", "Low Stock", "Out of Stock"]
                Material.accent: themeManager.primaryColor
                onCurrentTextChanged: {
                    switch(currentText) {
                        case "In Stock":
                            inventoryHandler.filterByStock("in_stock")
                            break
                        case "Low Stock":
                            inventoryHandler.filterByStock("low_stock")
                            break
                        case "Out of Stock":
                            inventoryHandler.filterByStock("out_of_stock")
                            break
                        default:
                            inventoryHandler.clearFilters()
                    }
                }
            }
        }
        
        // Inventory table
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
                            text: "Product"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 200
                        }
                        
                        Text {
                            text: "SKU"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 120
                        }
                        
                        Text {
                            text: "Current Stock"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                        
                        Text {
                            text: "Reserved"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Available"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Min Stock"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Value"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                        
                        Text {
                            text: "Actions"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // Inventory list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    model: inventory
                    
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
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 16
                            
                            // Product info
                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 2
                                
                                Text {
                                    text: modelData.product_name || "N/A"
                                    font.bold: true
                                    color: themeManager.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Last updated: " + new Date(modelData.last_updated).toLocaleDateString()
                                    font.pixelSize: 10
                                    color: themeManager.secondaryTextColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // SKU
                            Text {
                                Layout.preferredWidth: 120
                                text: modelData.product_sku || "N/A"
                                color: themeManager.textColor
                                elide: Text.ElideRight
                            }
                            
                            // Current stock
                            Text {
                                Layout.preferredWidth: 100
                                text: (modelData.quantity_on_hand || 0).toString()
                                color: getStockColor(modelData)
                                font.bold: true
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // Reserved
                            Text {
                                Layout.preferredWidth: 80
                                text: (modelData.quantity_reserved || 0).toString()
                                color: themeManager.secondaryTextColor
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // Available
                            Text {
                                Layout.preferredWidth: 80
                                text: getAvailableStock(modelData).toString()
                                color: themeManager.textColor
                                font.bold: true
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // Min stock
                            Text {
                                Layout.preferredWidth: 80
                                text: (modelData.minimum_quantity || 0).toString()
                                color: themeManager.secondaryTextColor
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // Value
                            Text {
                                Layout.preferredWidth: 100
                                text: "$" + ((modelData.quantity_on_hand || 0) * (modelData.unit_cost || 0)).toFixed(2)
                                color: themeManager.textColor
                                font.bold: true
                                horizontalAlignment: Text.AlignRight
                            }
                            
                            // Actions
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Button {
                                    text: "Adjust"
                                    flat: true
                                    Material.foreground: themeManager.primaryColor
                                    onClicked: {
                                        inventoryView.selectedItem = modelData
                                        stockAdjustmentDialog.open()
                                    }
                                }
                                
                                Button {
                                    text: "History"
                                    flat: true
                                    Material.foreground: themeManager.accentColor
                                    onClicked: {
                                        inventoryView.selectedItem = modelData
                                        movementHistoryDialog.open()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0 && !inventoryView.isLoading
                        anchors.centerIn: parent
                        text: "No inventory items found"
                        font.pixelSize: 16
                        color: themeManager.secondaryTextColor
                    }
                    
                    // Loading indicator
                    BusyIndicator {
                        visible: inventoryView.isLoading
                        anchors.centerIn: parent
                        Material.accent: themeManager.primaryColor
                        running: true
                    }
                }
            }
        }
    }
    
    // Stock Adjustment Dialog
    StockAdjustmentDialog {
        id: stockAdjustmentDialog
        inventoryItem: inventoryView.selectedItem
        
        onAccepted: {
            inventoryHandler.adjustStock(inventoryItem.id, adjustmentData)
        }
    }
    
    // Movement History Dialog
    MovementHistoryDialog {
        id: movementHistoryDialog
        inventoryItem: inventoryView.selectedItem
    }
    
    // Helper functions
    function getLowStockCount() {
        if (!inventory) return 0
        var count = 0
        for (var i = 0; i < inventory.length; i++) {
            var item = inventory[i]
            if ((item.quantity_on_hand || 0) <= (item.minimum_quantity || 0) && (item.quantity_on_hand || 0) > 0) {
                count++
            }
        }
        return count
    }
    
    function getOutOfStockCount() {
        if (!inventory) return 0
        var count = 0
        for (var i = 0; i < inventory.length; i++) {
            if ((inventory[i].quantity_on_hand || 0) === 0) {
                count++
            }
        }
        return count
    }
    
    function getTotalValue() {
        if (!inventory) return 0
        var total = 0
        for (var i = 0; i < inventory.length; i++) {
            var item = inventory[i]
            total += (item.quantity_on_hand || 0) * (item.unit_cost || 0)
        }
        return total
    }
    
    function getStockColor(item) {
        var stock = item.quantity_on_hand || 0
        var minStock = item.minimum_quantity || 0
        
        if (stock === 0) {
            return "#FF5722" // Red for out of stock
        } else if (stock <= minStock) {
            return themeManager.errorColor // Orange for low stock
        } else {
            return "#4CAF50" // Green for good stock
        }
    }
    
    function getAvailableStock(item) {
        return (item.quantity_on_hand || 0) - (item.quantity_reserved || 0)
    }
}
