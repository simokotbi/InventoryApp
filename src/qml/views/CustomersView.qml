import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Item {
    id: customersView
    
    property var customers: customerHandler.customers
    property bool isLoading: customerHandler.isLoading
    property bool showAddDialog: false
    property bool showEditDialog: false
    property var selectedCustomer: null
    
    Component.onCompleted: {
        customerHandler.loadCustomers()
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Customers"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            Button {
                text: "Add Customer"
                Material.background: themeManager.primaryColor
                Material.foreground: "white"
                onClicked: customersView.showAddDialog = true
            }
            
            Button {
                text: "Refresh"
                flat: true
                Material.foreground: themeManager.primaryColor
                onClicked: customerHandler.loadCustomers()
            }
        }
        
        // Search
        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Search customers by name, email, or phone..."
            Material.accent: themeManager.primaryColor
            onTextChanged: customerHandler.searchCustomers(text)
        }
        
        // Customers table
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
                            text: "Email"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 200
                        }
                        
                        Text {
                            text: "Phone"
                            font.bold: true
                            color: themeManager.textColor
                            Layout.preferredWidth: 150
                        }
                        
                        Text {
                            text: "Total Purchases"
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
                
                // Customers list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    model: customers
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 70
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
                            
                            // Customer name and info
                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 2
                                
                                Text {
                                    text: (modelData.first_name || "") + " " + (modelData.last_name || "")
                                    font.bold: true
                                    color: themeManager.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Customer since " + new Date(modelData.created_at || Date.now()).toLocaleDateString()
                                    font.pixelSize: 12
                                    color: themeManager.secondaryTextColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // Email
                            Text {
                                Layout.preferredWidth: 200
                                text: modelData.email || "N/A"
                                color: themeManager.textColor
                                elide: Text.ElideRight
                            }
                            
                            // Phone
                            Text {
                                Layout.preferredWidth: 150
                                text: modelData.phone || "N/A"
                                color: themeManager.textColor
                                elide: Text.ElideRight
                            }
                            
                            // Total purchases
                            Text {
                                Layout.preferredWidth: 120
                                text: "$" + (modelData.total_purchases || 0).toFixed(2)
                                color: themeManager.textColor
                                font.bold: true
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
                                        // Show customer details
                                        customersView.selectedCustomer = modelData
                                        customerDetailsDialog.open()
                                    }
                                }
                                
                                Button {
                                    text: "Edit"
                                    flat: true
                                    Material.foreground: themeManager.primaryColor
                                    onClicked: {
                                        customersView.selectedCustomer = modelData
                                        customersView.showEditDialog = true
                                    }
                                }
                                
                                Button {
                                    text: "Delete"
                                    flat: true
                                    Material.foreground: themeManager.errorColor
                                    onClicked: {
                                        deleteConfirmDialog.customerToDelete = modelData
                                        deleteConfirmDialog.open()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0 && !customersView.isLoading
                        anchors.centerIn: parent
                        text: "No customers found"
                        font.pixelSize: 16
                        color: themeManager.secondaryTextColor
                    }
                    
                    // Loading indicator
                    BusyIndicator {
                        visible: customersView.isLoading
                        anchors.centerIn: parent
                        Material.accent: themeManager.primaryColor
                        running: true
                    }
                }
            }
        }
    }
    
    // Add/Edit Customer Dialog
    CustomerDialog {
        id: customerDialog
        visible: customersView.showAddDialog || customersView.showEditDialog
        isEdit: customersView.showEditDialog
        customer: customersView.selectedCustomer
        
        onAccepted: {
            if (isEdit) {
                customerHandler.updateCustomer(customer.id, customerData)
            } else {
                customerHandler.addCustomer(customerData)
            }
            customersView.showAddDialog = false
            customersView.showEditDialog = false
            customersView.selectedCustomer = null
        }
        
        onRejected: {
            customersView.showAddDialog = false
            customersView.showEditDialog = false
            customersView.selectedCustomer = null
        }
    }
    
    // Customer Details Dialog
    CustomerDetailsDialog {
        id: customerDetailsDialog
        customer: customersView.selectedCustomer
    }
    
    // Delete confirmation dialog
    MessagePopup {
        id: deleteConfirmDialog
        title: "Delete Customer"
        message: "Are you sure you want to delete this customer? This action cannot be undone."
        type: "warning"
        
        property var customerToDelete: null
        
        onAccepted: {
            if (customerToDelete) {
                customerHandler.deleteCustomer(customerToDelete.id)
                customerToDelete = null
            }
        }
    }
}
