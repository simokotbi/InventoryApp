import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: productDialog
    
    property bool isEdit: false
    property var product: null
    property var productData: ({
        name: nameField.text,
        description: descriptionField.text,
        sku: skuField.text,
        category: categoryCombo.currentText,
        price: parseFloat(priceField.text) || 0,
        cost: parseFloat(costField.text) || 0,
        stock_quantity: parseInt(stockField.text) || 0,
        low_stock_threshold: parseInt(thresholdField.text) || 10,
        is_active: activeSwitch.checked
    })
    
    title: isEdit ? "Edit Product" : "Add Product"
    modal: true
    anchors.centerIn: parent
    width: 500
    height: 600
    
    Material.accent: themeManager.primaryColor
    
    // Reset form when dialog opens
    onOpened: {
        if (isEdit && product) {
            nameField.text = product.name || ""
            descriptionField.text = product.description || ""
            skuField.text = product.sku || ""
            categoryCombo.currentIndex = categoryCombo.find(product.category || "Other")
            priceField.text = (product.price || 0).toString()
            costField.text = (product.cost || 0).toString()
            stockField.text = (product.stock_quantity || 0).toString()
            thresholdField.text = (product.low_stock_threshold || 10).toString()
            activeSwitch.checked = product.is_active !== false
        } else {
            // Reset form for new product
            nameField.text = ""
            descriptionField.text = ""
            skuField.text = ""
            categoryCombo.currentIndex = 0
            priceField.text = "0.00"
            costField.text = "0.00"
            stockField.text = "0"
            thresholdField.text = "10"
            activeSwitch.checked = true
        }
    }
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            // Product Name
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Product Name *"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Enter product name"
                    Material.accent: themeManager.primaryColor
                }
            }
            
            // Description
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Description"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    TextArea {
                        id: descriptionField
                        placeholderText: "Enter product description"
                        Material.accent: themeManager.primaryColor
                        wrapMode: TextArea.Wrap
                    }
                }
            }
            
            // SKU and Category
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "SKU *"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: skuField
                        Layout.fillWidth: true
                        placeholderText: "Enter SKU"
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Category"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    ComboBox {
                        id: categoryCombo
                        Layout.fillWidth: true
                        model: ["Electronics", "Clothing", "Food", "Books", "Other"]
                        Material.accent: themeManager.primaryColor
                    }
                }
            }
            
            // Price and Cost
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Price *"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: priceField
                        Layout.fillWidth: true
                        placeholderText: "0.00"
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Cost"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: costField
                        Layout.fillWidth: true
                        placeholderText: "0.00"
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        Material.accent: themeManager.primaryColor
                    }
                }
            }
            
            // Stock and Threshold
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Stock Quantity"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: stockField
                        Layout.fillWidth: true
                        placeholderText: "0"
                        validator: IntValidator { bottom: 0 }
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Low Stock Threshold"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: thresholdField
                        Layout.fillWidth: true
                        placeholderText: "10"
                        validator: IntValidator { bottom: 0 }
                        Material.accent: themeManager.primaryColor
                    }
                }
            }
            
            // Active status
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Active"
                    color: themeManager.textColor
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                Switch {
                    id: activeSwitch
                    checked: true
                    Material.accent: themeManager.primaryColor
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    // Validation
    property bool isValid: nameField.text.trim() !== "" && 
                          skuField.text.trim() !== "" && 
                          parseFloat(priceField.text) > 0
    
    onAccepted: {
        if (!isValid) {
            // Show validation error
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
            onClicked: productDialog.reject()
        }
        
        Button {
            text: productDialog.isEdit ? "Update" : "Add"
            enabled: productDialog.isValid
            Material.background: themeManager.primaryColor
            Material.foreground: "white"
            onClicked: productDialog.accept()
        }
    }
    
    // Validation error dialog
    MessagePopup {
        id: validationError
        title: "Validation Error"
        message: "Please fill in all required fields (Name, SKU, Price)"
        type: "error"
    }
}
