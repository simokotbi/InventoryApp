import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Item {
    id: productsView
    
    property var products: productHandler.products
    property bool isLoading: productHandler.isLoading
    property bool showAddDialog: false
    property bool showEditDialog: false
    property var selectedProduct: null
    
    Component.onCompleted: {
        productHandler.loadProducts()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Products"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            Button {
                text: "Add Product"
                Material.background: themeManager.primaryColor
                Material.foreground: "white"
                onClicked: productsView.showAddDialog = true
            }
            
            Button {
                text: "Refresh"
                flat: true
                Material.foreground: themeManager.primaryColor
                onClicked: productHandler.loadProducts()
            }
        }
        
        // Search and filters
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search products..."
                Material.accent: themeManager.primaryColor
                onTextChanged: productHandler.searchProducts(text)
            }
            
            ComboBox {
                id: categoryFilter
                Layout.preferredWidth: 150
                model: ["All Categories", "Electronics", "Clothing", "Food", "Books", "Other"]
                Material.accent: themeManager.primaryColor
                onCurrentTextChanged: {
                    if (currentText !== "All Categories") {
                        productHandler.filterByCategory(currentText)
                    } else {
                        productHandler.clearFilters()
                    }
                }
            }
        }
        
        // Products table
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
                            text: "Name"
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
                            text: "Category"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 100
                        }
                        
                        Text {
                            text: "Price"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Stock"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Actions"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // Products list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    model: products
                    
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
                            
                            // Product name
                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 2
                                
                                Text {
                                    text: modelData.name || "N/A"
                                    font.bold: true
                                    color: themeManager.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: modelData.description || ""
                                    font.pixelSize: 12
                                    color: themeManager.secondaryTextColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // SKU
                            Text {
                                Layout.preferredWidth: 120
                                text: modelData.sku || "N/A"
                                color: themeManager.textColor
                                elide: Text.ElideRight
                            }
                            
                            // Category
                            Rectangle {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 24
                                color: themeManager.accentColor
                                radius: 12
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.category || "Other"
                                    color: "white"
                                    font.pixelSize: 10
                                }
                            }
                            
                            // Price
                            Text {
                                Layout.preferredWidth: 80
                                text: "$" + (modelData.price || 0).toFixed(2)
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            // Stock
                            Text {
                                Layout.preferredWidth: 80
                                text: (modelData.stock_quantity || 0).toString()
                                color: (modelData.stock_quantity || 0) < (modelData.low_stock_threshold || 10) ? 
                                      themeManager.errorColor : themeManager.textColor
                                font.bold: (modelData.stock_quantity || 0) < (modelData.low_stock_threshold || 10)
                            }
                            
                            // Actions
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Button {
                                    text: "Edit"
                                    flat: true
                                    Material.foreground: themeManager.primaryColor
                                    onClicked: {
                                        productsView.selectedProduct = modelData
                                        productsView.showEditDialog = true
                                    }
                                }
                                
                                Button {
                                    text: "Delete"
                                    flat: true
                                    Material.foreground: themeManager.errorColor
                                    onClicked: {
                                        deleteConfirmDialog.productToDelete = modelData
                                        deleteConfirmDialog.open()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0 && !productsView.isLoading
                        anchors.centerIn: parent
                        text: "No products found"
                        font.pixelSize: 16
                        color: themeManager.secondaryTextColor
                    }
                    
                    // Loading indicator
                    BusyIndicator {
                        visible: productsView.isLoading
                        anchors.centerIn: parent
                        Material.accent: themeManager.primaryColor
                        running: true
                    }
                }
            }
        }
    }
    
    // Add/Edit Product Dialog
    ProductDialog {
        id: productDialog
        visible: productsView.showAddDialog || productsView.showEditDialog
        isEdit: productsView.showEditDialog
        product: productsView.selectedProduct
        
        onAccepted: {
            if (isEdit) {
                productHandler.updateProduct(product.id, productData)
            } else {
                productHandler.addProduct(productData)
            }
            productsView.showAddDialog = false
            productsView.showEditDialog = false
            productsView.selectedProduct = null
        }
        
        onRejected: {
            productsView.showAddDialog = false
            productsView.showEditDialog = false
            productsView.selectedProduct = null
        }
    }
    
    // Delete confirmation dialog
    MessagePopup {
        id: deleteConfirmDialog
        title: "Delete Product"
        message: "Are you sure you want to delete this product? This action cannot be undone."
        type: "warning"
        
        property var productToDelete: null
        
        onAccepted: {
            if (productToDelete) {
                productHandler.deleteProduct(productToDelete.id)
                productToDelete = null
            }
        }
    }
}
