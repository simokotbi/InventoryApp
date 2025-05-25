import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: movementHistoryDialog
    
    property var inventoryItem: null
    property var movements: inventoryHandler.movements || []
    
    title: "Movement History - " + (inventoryItem ? inventoryItem.product_name : "")
    modal: true
    anchors.centerIn: parent
    width: 800
    height: 600
    
    Material.accent: themeManager.primaryColor
    
    onOpened: {
        if (inventoryItem) {
            inventoryHandler.loadMovementHistory(inventoryItem.product_id)
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Product info header
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
                
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    color: themeManager.primaryColor
                    radius: 25
                    
                    Text {
                        anchors.centerIn: parent
                        text: "📦"
                        font.pixelSize: 20
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: inventoryItem ? inventoryItem.product_name || "N/A" : "N/A"
                        font.pixelSize: 16
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    RowLayout {
                        spacing: 16
                        
                        Text {
                            text: "SKU: " + (inventoryItem ? inventoryItem.product_sku || "N/A" : "N/A")
                            font.pixelSize: 12
                            color: themeManager.secondaryTextColor
                        }
                        
                        Text {
                            text: "Current Stock: " + (inventoryItem ? (inventoryItem.quantity_on_hand || 0).toString() : "0")
                            font.pixelSize: 12
                            color: themeManager.accentColor
                            font.bold: true
                        }
                    }
                }
                
                Button {
                    text: "Refresh"
                    flat: true
                    Material.foreground: themeManager.primaryColor
                    onClicked: {
                        if (inventoryItem) {
                            inventoryHandler.loadMovementHistory(inventoryItem.product_id)
                        }
                    }
                }
            }
        }
        
        // Filters
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            ComboBox {
                id: typeFilter
                Layout.preferredWidth: 150
                model: ["All Types", "In", "Out", "Adjustment"]
                Material.accent: themeManager.primaryColor
                onCurrentTextChanged: {
                    filterMovements()
                }
            }
            
            ComboBox {
                id: dateFilter
                Layout.preferredWidth: 150
                model: ["All Time", "Today", "This Week", "This Month", "Last 30 Days"]
                Material.accent: themeManager.primaryColor
                onCurrentTextChanged: {
                    filterMovements()
                }
            }
            
            Item {
                Layout.fillWidth: true
            }
            
            Text {
                text: filteredMovements.length + " movements"
                color: themeManager.secondaryTextColor
                font.pixelSize: 12
            }
        }
        
        // Movements table
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
                            text: "Date"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                        
                        Text {
                            text: "Type"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Quantity"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Previous"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "New Stock"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Reason"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "Reference"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                    }
                }
                
                // Movements list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    model: filteredMovements
                    
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
                            
                            // Date
                            Text {
                                Layout.preferredWidth: 100
                                text: new Date(modelData.movement_date || Date.now()).toLocaleDateString()
                                color: themeManager.textColor
                                font.pixelSize: 12
                            }
                            
                            // Type
                            Rectangle {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 24
                                color: getTypeColor(modelData.movement_type)
                                radius: 12
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: (modelData.movement_type || "").toUpperCase()
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            // Quantity
                            Text {
                                Layout.preferredWidth: 80
                                text: getQuantityText(modelData)
                                color: getQuantityColor(modelData.movement_type)
                                font.bold: true
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // Previous stock
                            Text {
                                Layout.preferredWidth: 80
                                text: (modelData.previous_stock || 0).toString()
                                color: themeManager.secondaryTextColor
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // New stock
                            Text {
                                Layout.preferredWidth: 80
                                text: (modelData.new_stock || 0).toString()
                                color: themeManager.textColor
                                font.bold: true
                                horizontalAlignment: Text.AlignCenter
                            }
                            
                            // Reason
                            Text {
                                Layout.fillWidth: true
                                text: modelData.reason || "No reason provided"
                                color: themeManager.textColor
                                elide: Text.ElideRight
                                font.pixelSize: 12
                            }
                            
                            // Reference
                            Text {
                                Layout.preferredWidth: 100
                                text: modelData.reference_id || "-"
                                color: themeManager.secondaryTextColor
                                elide: Text.ElideRight
                                font.pixelSize: 11
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0
                        anchors.centerIn: parent
                        text: "No movement history found"
                        font.pixelSize: 14
                        color: themeManager.secondaryTextColor
                    }
                }
            }
        }
    }
    
    standardButtons: Dialog.Close
    
    // Filtered movements based on filters
    property var filteredMovements: {
        if (!movements) return []
        
        var filtered = movements.slice() // Make a copy
        
        // Filter by type
        if (typeFilter.currentText !== "All Types") {
            filtered = filtered.filter(function(movement) {
                return movement.movement_type === typeFilter.currentText.toLowerCase()
            })
        }
        
        // Filter by date
        if (dateFilter.currentText !== "All Time") {
            var now = new Date()
            var filterDate = new Date()
            
            switch(dateFilter.currentText) {
                case "Today":
                    filterDate.setHours(0, 0, 0, 0)
                    break
                case "This Week":
                    filterDate.setDate(now.getDate() - now.getDay())
                    filterDate.setHours(0, 0, 0, 0)
                    break
                case "This Month":
                    filterDate.setDate(1)
                    filterDate.setHours(0, 0, 0, 0)
                    break
                case "Last 30 Days":
                    filterDate.setDate(now.getDate() - 30)
                    filterDate.setHours(0, 0, 0, 0)
                    break
            }
            
            filtered = filtered.filter(function(movement) {
                var movementDate = new Date(movement.movement_date)
                return movementDate >= filterDate
            })
        }
        
        return filtered
    }
    
    // Helper functions
    function getTypeColor(type) {
        switch(type) {
            case "in": return "#4CAF50"
            case "out": return "#FF5722"
            case "adjustment": return "#FF9800"
            default: return themeManager.secondaryTextColor
        }
    }
    
    function getQuantityText(movement) {
        var quantity = movement.quantity || 0
        switch(movement.movement_type) {
            case "in":
                return "+" + quantity.toString()
            case "out":
                return "-" + quantity.toString()
            case "adjustment":
                var diff = (movement.new_stock || 0) - (movement.previous_stock || 0)
                return (diff >= 0 ? "+" : "") + diff.toString()
            default:
                return quantity.toString()
        }
    }
    
    function getQuantityColor(type) {
        switch(type) {
            case "in": return "#4CAF50"
            case "out": return "#FF5722"
            case "adjustment": return "#FF9800"
            default: return themeManager.textColor
        }
    }
    
    function filterMovements() {
        // Trigger property binding update
        filteredMovementsChanged()
    }
}
