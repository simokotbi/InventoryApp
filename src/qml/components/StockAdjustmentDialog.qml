import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: stockAdjustmentDialog
    
    property var inventoryItem: null
    property var adjustmentData: ({
        movement_type: adjustmentTypeCombo.currentText.toLowerCase(),
        quantity: parseFloat(quantityField.text) || 0,
        reason: reasonField.text,
        reference_id: referenceField.text
    })
    
    title: "Stock Adjustment - " + (inventoryItem ? inventoryItem.product_name : "")
    modal: true
    anchors.centerIn: parent
    width: 500
    height: 600
    
    Material.accent: themeManager.primaryColor
    
    onOpened: {
        if (inventoryItem) {
            currentStockText.text = (inventoryItem.quantity_on_hand || 0).toString()
            quantityField.text = "0"
            reasonField.text = ""
            referenceField.text = ""
            adjustmentTypeCombo.currentIndex = 0
        }
    }
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            // Current inventory info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: themeManager.surfaceColor
                border.color: themeManager.dividerColor
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    
                    Text {
                        text: "Current Stock Information"
                        font.pixelSize: 14
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Product:"
                                font.bold: true
                                color: themeManager.textColor
                                font.pixelSize: 12
                            }
                            
                            Text {
                                text: inventoryItem ? inventoryItem.product_name || "N/A" : "N/A"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "SKU:"
                                font.bold: true
                                color: themeManager.textColor
                                font.pixelSize: 12
                            }
                            
                            Text {
                                text: inventoryItem ? inventoryItem.product_sku || "N/A" : "N/A"
                                color: themeManager.secondaryTextColor
                                font.pixelSize: 12
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Current Stock:"
                                font.bold: true
                                color: themeManager.textColor
                                font.pixelSize: 12
                            }
                            
                            Text {
                                id: currentStockText
                                text: inventoryItem ? (inventoryItem.quantity_on_hand || 0).toString() : "0"
                                color: themeManager.accentColor
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }
            }
            
            // Adjustment type
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Adjustment Type *"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                ComboBox {
                    id: adjustmentTypeCombo
                    Layout.fillWidth: true
                    model: ["In", "Out", "Adjustment"]
                    Material.accent: themeManager.primaryColor
                    
                    onCurrentTextChanged: {
                        updateNewStockPreview()
                    }
                }
            }
            
            // Quantity
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Quantity *"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                TextField {
                    id: quantityField
                    Layout.fillWidth: true
                    placeholderText: "Enter quantity to adjust"
                    validator: DoubleValidator { bottom: 0 }
                    Material.accent: themeManager.primaryColor
                    
                    onTextChanged: {
                        updateNewStockPreview()
                    }
                }
                
                Text {
                    text: getQuantityHelpText()
                    color: themeManager.secondaryTextColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            
            // Preview new stock level
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Qt.lighter(themeManager.primaryColor, 1.9)
                border.color: themeManager.primaryColor
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Text {
                        text: "New Stock Level:"
                        font.bold: true
                        color: themeManager.textColor
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        id: newStockText
                        text: calculateNewStock().toString()
                        font.bold: true
                        font.pixelSize: 16
                        color: getNewStockColor()
                    }
                }
            }
            
            // Reason
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Reason *"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                ComboBox {
                    id: reasonCombo
                    Layout.fillWidth: true
                    editable: true
                    model: [
                        "Damaged goods",
                        "Expired items",
                        "Theft/Loss",
                        "Supplier return",
                        "Customer return",
                        "Recount adjustment",
                        "Transfer in",
                        "Transfer out",
                        "Promotion/Sample",
                        "Other"
                    ]
                    Material.accent: themeManager.primaryColor
                    
                    onAccepted: {
                        reasonField.text = editText
                    }
                    
                    onCurrentTextChanged: {
                        if (currentText !== "Other") {
                            reasonField.text = currentText
                        }
                    }
                }
                
                TextField {
                    id: reasonField
                    Layout.fillWidth: true
                    placeholderText: "Enter reason for adjustment"
                    Material.accent: themeManager.primaryColor
                    visible: reasonCombo.currentText === "Other" || reasonCombo.editText !== ""
                }
            }
            
            // Reference ID
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Reference ID"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                TextField {
                    id: referenceField
                    Layout.fillWidth: true
                    placeholderText: "Purchase order, transfer ID, etc. (optional)"
                    Material.accent: themeManager.primaryColor
                }
                
                Text {
                    text: "Optional reference number for tracking this adjustment"
                    color: themeManager.secondaryTextColor
                    font.pixelSize: 11
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    // Validation
    property bool isValid: quantityField.text.trim() !== "" && 
                          parseFloat(quantityField.text) > 0 &&
                          reasonField.text.trim() !== ""
    
    onAccepted: {
        if (!isValid) {
            validationError.open()
            return
        }
    }
    
    // Custom button styling
    footer: RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 8
        
        Button {
            text: "Cancel"
            flat: true
            Material.foreground: themeManager.secondaryTextColor
            onClicked: stockAdjustmentDialog.reject()
        }
        
        Button {
            text: "Apply Adjustment"
            enabled: stockAdjustmentDialog.isValid
            Material.background: themeManager.primaryColor
            Material.foreground: "white"
            onClicked: stockAdjustmentDialog.accept()
        }
    }
    
    // Helper functions
    function getQuantityHelpText() {
        switch(adjustmentTypeCombo.currentText) {
            case "In":
                return "Enter quantity to add to current stock"
            case "Out":
                return "Enter quantity to remove from current stock"
            case "Adjustment":
                return "Enter the actual stock count (will calculate difference)"
            default:
                return ""
        }
    }
    
    function calculateNewStock() {
        var currentStock = inventoryItem ? (inventoryItem.quantity_on_hand || 0) : 0
        var quantity = parseFloat(quantityField.text) || 0
        
        switch(adjustmentTypeCombo.currentText) {
            case "In":
                return currentStock + quantity
            case "Out":
                return Math.max(0, currentStock - quantity)
            case "Adjustment":
                return quantity
            default:
                return currentStock
        }
    }
    
    function getNewStockColor() {
        var newStock = calculateNewStock()
        var minStock = inventoryItem ? (inventoryItem.minimum_quantity || 0) : 0
        
        if (newStock === 0) {
            return "#FF5722" // Red for out of stock
        } else if (newStock <= minStock) {
            return themeManager.errorColor // Orange for low stock
        } else {
            return "#4CAF50" // Green for good stock
        }
    }
    
    function updateNewStockPreview() {
        newStockText.text = calculateNewStock().toString()
        newStockText.color = getNewStockColor()
    }
    
    // Validation error dialog
    MessagePopup {
        id: validationError
        title: "Validation Error"
        message: "Please fill in all required fields and ensure quantity is greater than 0"
        type: "error"
    }
}
