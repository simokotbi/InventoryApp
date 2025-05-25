import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: newSaleDialog
    
    property var saleData: ({
        customer_id: customerCombo.currentValue,
        items: saleItems,
        notes: notesField.text,
        discount: parseFloat(discountField.text) || 0,
        tax_rate: parseFloat(taxField.text) || 0
    })
    
    property var saleItems: []
    property real subtotal: calculateSubtotal()
    property real discount: parseFloat(discountField.text) || 0
    property real tax: subtotal * (parseFloat(taxField.text) || 0) / 100
    property real total: subtotal - discount + tax
    
    title: "New Sale"
    modal: true
    anchors.centerIn: parent
    width: 800
    height: 700
    
    Material.accent: themeManager.primaryColor
    
    onOpened: {
        // Reset form
        saleItems = []
        customerCombo.currentIndex = 0
        notesField.text = ""
        discountField.text = "0"
        taxField.text = "0"
        
        // Load data
        customerHandler.loadCustomers()
        productHandler.loadProducts()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Customer selection
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            Text {
                text: "Customer:"
                color: themeManager.textColor
                font.bold: true
                Layout.preferredWidth: 80
            }
            
            ComboBox {
                id: customerCombo
                Layout.fillWidth: true
                textRole: "display"
                valueRole: "value"
                Material.accent: themeManager.primaryColor
                
                model: ListModel {
                    id: customerModel
                    ListElement { display: "Walk-in Customer"; value: null }
                }
                
                Component.onCompleted: {
                    customerHandler.customersChanged.connect(updateCustomerModel)
                    updateCustomerModel()
                }
                
                function updateCustomerModel() {
                    customerModel.clear()
                    customerModel.append({ display: "Walk-in Customer", value: null })
                    
                    var customers = customerHandler.customers || []
                    for (var i = 0; i < customers.length; i++) {
                        var customer = customers[i]
                        customerModel.append({
                            display: customer.first_name + " " + customer.last_name,
                            value: customer.id
                        })
                    }
                }
            }
            
            Button {
                text: "New Customer"
                flat: true
                Material.foreground: themeManager.primaryColor
                onClicked: {
                    // Open new customer dialog
                    newCustomerDialog.open()
                }
            }
        }
        
        // Product selection
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            TextField {
                id: productSearch
                Layout.fillWidth: true
                placeholderText: "Search products by name or SKU..."
                Material.accent: themeManager.primaryColor
                onTextChanged: productHandler.searchProducts(text)
            }
            
            ComboBox {
                id: productCombo
                Layout.preferredWidth: 300
                textRole: "display"
                valueRole: "value"
                Material.accent: themeManager.primaryColor
                
                model: ListModel {
                    id: productModel
                }
                
                Component.onCompleted: {
                    productHandler.productsChanged.connect(updateProductModel)
                    updateProductModel()
                }
                
                function updateProductModel() {
                    productModel.clear()
                    
                    var products = productHandler.products || []
                    for (var i = 0; i < products.length; i++) {
                        var product = products[i]
                        productModel.append({
                            display: product.name + " - $" + product.price.toFixed(2),
                            value: product
                        })
                    }
                }
            }
            
            SpinBox {
                id: quantitySpinner
                from: 1
                to: 999
                value: 1
                Material.accent: themeManager.primaryColor
            }
            
            Button {
                text: "Add Item"
                Material.background: themeManager.accentColor
                Material.foreground: "white"
                enabled: productCombo.currentValue !== undefined
                onClicked: addItem()
            }
        }
        
        // Sale items table
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
                            text: "Total"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Actions"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 60
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
                        height: 40
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.02)
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 16
                            
                            Text {
                                text: modelData.product.name
                                color: themeManager.textColor
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                text: modelData.quantity.toString()
                                color: themeManager.textColor
                                Layout.preferredWidth: 50
                                horizontalAlignment: Text.AlignRight
                            }
                            
                            Text {
                                text: "$" + modelData.product.price.toFixed(2)
                                color: themeManager.textColor
                                Layout.preferredWidth: 80
                                horizontalAlignment: Text.AlignRight
                            }
                            
                            Text {
                                text: "$" + (modelData.quantity * modelData.product.price).toFixed(2)
                                color: themeManager.textColor
                                font.bold: true
                                Layout.preferredWidth: 80
                                horizontalAlignment: Text.AlignRight
                            }
                            
                            Button {
                                text: "✕"
                                flat: true
                                Material.foreground: themeManager.errorColor
                                Layout.preferredWidth: 60
                                onClicked: removeItem(index)
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0
                        anchors.centerIn: parent
                        text: "No items added yet"
                        font.pixelSize: 14
                        color: themeManager.secondaryTextColor
                    }
                }
            }
        }
        
        // Sale summary
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
                
                // Notes and adjustments
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "Notes"
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    TextArea {
                        id: notesField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        placeholderText: "Add sale notes..."
                        Material.accent: themeManager.primaryColor
                        wrapMode: TextArea.Wrap
                    }
                    
                    RowLayout {
                        spacing: 16
                        
                        Text {
                            text: "Discount: $"
                            color: themeManager.textColor
                        }
                        
                        TextField {
                            id: discountField
                            text: "0"
                            validator: DoubleValidator { bottom: 0 }
                            Material.accent: themeManager.primaryColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Tax %:"
                            color: themeManager.textColor
                        }
                        
                        TextField {
                            id: taxField
                            text: "0"
                            validator: DoubleValidator { bottom: 0; top: 100 }
                            Material.accent: themeManager.primaryColor
                            Layout.preferredWidth: 80
                        }
                    }
                }
                
                // Totals
                ColumnLayout {
                    Layout.preferredWidth: 200
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Subtotal:"
                            color: themeManager.textColor
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "$" + subtotal.toFixed(2)
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
                            text: "-$" + discount.toFixed(2)
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
                            text: "$" + tax.toFixed(2)
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
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "$" + total.toFixed(2)
                            color: themeManager.primaryColor
                            font.bold: true
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }
    }
    
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    // Validation
    property bool isValid: saleItems.length > 0 && total > 0
    
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
            onClicked: newSaleDialog.reject()
        }
        
        Button {
            text: "Complete Sale"
            enabled: newSaleDialog.isValid
            Material.background: themeManager.primaryColor
            Material.foreground: "white"
            onClicked: newSaleDialog.accept()
        }
    }
    
    // Functions
    function addItem() {
        var product = productCombo.currentValue
        var quantity = quantitySpinner.value
        
        if (!product) return
        
        // Check if item already exists
        for (var i = 0; i < saleItems.length; i++) {
            if (saleItems[i].product.id === product.id) {
                saleItems[i].quantity += quantity
                saleItemsChanged()
                return
            }
        }
        
        // Add new item
        saleItems.push({
            product: product,
            quantity: quantity
        })
        saleItemsChanged()
        
        // Reset selection
        productCombo.currentIndex = -1
        quantitySpinner.value = 1
    }
    
    function removeItem(index) {
        saleItems.splice(index, 1)
        saleItemsChanged()
    }
    
    function calculateSubtotal() {
        var total = 0
        for (var i = 0; i < saleItems.length; i++) {
            total += saleItems[i].quantity * saleItems[i].product.price
        }
        return total
    }
    
    // Validation error dialog
    MessagePopup {
        id: validationError
        title: "Validation Error"
        message: "Please add at least one item to the sale"
        type: "error"
    }
    
    // New customer dialog
    CustomerDialog {
        id: newCustomerDialog
        
        onAccepted: {
            customerHandler.addCustomer(customerData)
        }
    }
}
