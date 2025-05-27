import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"
import "../components"

Rectangle {
    id: root
    
    property bool isOnlineMode: true
    property var selectedProduct: null
    
    color: Theme.backgroundColor
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing * 2
        spacing: Theme.spacing * 2
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Products"
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.textColor
                Layout.fillWidth: true
            }
            
            CustomButton {
                text: "Sync"
                variant: "secondary"
                enabled: !root.isOnlineMode
                onClicked: console.log("Sync products")
            }
        }
        
        // Search and filters
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing
            
            CustomInput {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search products..."
                onTextChanged: filterProducts()
            }
            
            ComboBox {
                id: categoryFilter
                model: ["All Categories", "Electronics", "Accessories", "Software"]
                Layout.preferredWidth: 200
                onCurrentTextChanged: filterProducts()
            }
            
            ComboBox {
                id: stockFilter
                model: ["All Stock", "In Stock", "Low Stock", "Out of Stock"]
                Layout.preferredWidth: 150
                onCurrentTextChanged: filterProducts()
            }
        }
        
        // Products table
        DataTableView {
            id: productsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            columns: [
                {
                    "field": "name",
                    "title": "Product Name",
                    "width": 250,
                    "sortable": true
                },
                {
                    "field": "category",
                    "title": "Category",
                    "width": 150,
                    "sortable": true
                },
                {
                    "field": "price",
                    "title": "Price",
                    "width": 100,
                    "sortable": true,
                    "format": function(value) { return "$" + parseFloat(value).toFixed(2) }
                },
                {
                    "field": "stock_quantity",
                    "title": "Stock",
                    "width": 100,
                    "sortable": true
                },
                {
                    "field": "status",
                    "title": "Status",
                    "width": 120,
                    "sortable": true
                }
            ]
            
            model: ListModel {
                id: productsModel
                
                ListElement {
                    id: 1
                    name: "Gaming Mouse X1"
                    category: "Electronics"
                    price: 45.99
                    stock_quantity: 25
                    status: "Active"
                    description: "High-precision gaming mouse with RGB lighting"
                }
                ListElement {
                    id: 2
                    name: "Wireless Keyboard"
                    category: "Electronics"
                    price: 89.99
                    stock_quantity: 12
                    status: "Active"
                    description: "Mechanical wireless keyboard"
                }
                ListElement {
                    id: 3
                    name: "USB Cable"
                    category: "Accessories"
                    price: 12.99
                    stock_quantity: 5
                    status: "Low Stock"
                    description: "USB-C to USB-A cable, 2 meters"
                }
                ListElement {
                    id: 4
                    name: "Software License"
                    category: "Software"
                    price: 199.99
                    stock_quantity: 0
                    status: "Digital"
                    description: "Annual software license"
                }
            }
            
            onRowClicked: function(row, rowData) {
                root.selectedProduct = rowData
                productDetailsPanel.visible = true
            }
            
            onRowDoubleClicked: function(row, rowData) {
                editProductDialog.product = rowData
                editProductDialog.open()
            }
        }
    }
    
    // Product details panel
    Rectangle {
        id: productDetailsPanel
        width: 300
        height: parent.height
        anchors.right: parent.right
        color: Theme.cardColor
        border.color: Theme.borderColor
        border.width: 1
        visible: false
        
        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacing
            spacing: Theme.spacing
            
            Row {
                width: parent.width
                
                Text {
                    text: "Product Details"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.textColor
                    width: parent.width - 30
                }
                
                SvgIcon {
                    source: "qrc:/assets/icons/x.svg"
                    size: 20
                    color: Theme.textColorSecondary
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: productDetailsPanel.visible = false
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.borderColor
            }
            
            Column {
                width: parent.width
                spacing: Theme.spacingSmall
                visible: root.selectedProduct !== null
                
                Text {
                    text: root.selectedProduct ? root.selectedProduct.name : ""
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    color: Theme.textColor
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                
                Text {
                    text: root.selectedProduct ? root.selectedProduct.description : ""
                    font.pixelSize: Theme.fontSize
                    color: Theme.textColorSecondary
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                
                Row {
                    spacing: Theme.spacing
                    
                    Text {
                        text: "Price:"
                        font.pixelSize: Theme.fontSize
                        color: Theme.textColorSecondary
                    }
                    
                    Text {
                        text: root.selectedProduct ? "$" + parseFloat(root.selectedProduct.price).toFixed(2) : ""
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Bold
                        color: Theme.textColor
                    }
                }
                
                Row {
                    spacing: Theme.spacing
                    
                    Text {
                        text: "Stock:"
                        font.pixelSize: Theme.fontSize
                        color: Theme.textColorSecondary
                    }
                    
                    Text {
                        text: root.selectedProduct ? root.selectedProduct.stock_quantity.toString() : ""
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Bold
                        color: root.selectedProduct && root.selectedProduct.stock_quantity < 10 ? 
                               Theme.errorColor : Theme.textColor
                    }
                }
                
                Row {
                    spacing: Theme.spacing
                    
                    Text {
                        text: "Category:"
                        font.pixelSize: Theme.fontSize
                        color: Theme.textColorSecondary
                    }
                    
                    Text {
                        text: root.selectedProduct ? root.selectedProduct.category : ""
                        font.pixelSize: Theme.fontSize
                        color: Theme.textColor
                    }
                }
                
                CustomButton {
                    text: "Edit Product"                    width: parent.width
                    variant: "primary"
                    onClicked: {
                        editProductDialog.product = root.selectedProduct
                        editProductDialog.open()
                    }
                }
                
                CustomButton {
                    text: "Delete Product"
                    width: parent.width
                    primary: false
                    onClicked: deleteConfirmDialog.open()
                }
            }
        }
    }
    
    function filterProducts() {
        // Placeholder for filtering logic
        console.log("Filtering products:", searchInput.text, categoryFilter.currentText, stockFilter.currentText)
    }
    
    // Add Product Dialog
    MessagePopup {
        id: addProductDialog
        title: "Add New Product"
        message: "Product addition form would go here"
        type: "info"
        autoClose: false
    }
    
    // Edit Product Dialog
    MessagePopup {
        id: editProductDialog
        title: "Edit Product"
        message: "Product editing form would go here"
        type: "info"
        autoClose: false
        
        property var product: null
    }
    
    // Delete Confirmation Dialog
    MessagePopup {
        id: deleteConfirmDialog
        title: "Delete Product"
        message: "Are you sure you want to delete this product? This action cannot be undone."
        type: "warning"
        autoClose: false
        
        onAccepted: {
            console.log("Deleting product:", root.selectedProduct.name)
            // Remove from model logic would go here
            productDetailsPanel.visible = false
        }
    }
}
