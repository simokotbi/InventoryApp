import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: customerDetailsDialog
    
    property var customer: null
    property var customerPurchases: customerHandler.customerPurchases
    
    title: customer ? (customer.first_name + " " + customer.last_name) : "Customer Details"
    modal: true
    anchors.centerIn: parent
    width: 600
    height: 500
    
    Material.accent: themeManager.primaryColor
    
    onOpened: {
        if (customer) {
            customerHandler.loadCustomerPurchases(customer.id)
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Customer info
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
                
                // Avatar
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    color: themeManager.primaryColor
                    radius: 40
                    
                    Text {
                        anchors.centerIn: parent
                        text: customer ? (customer.first_name.charAt(0) + customer.last_name.charAt(0)).toUpperCase() : "?"
                        color: "white"
                        font.pixelSize: 28
                        font.bold: true
                    }
                }
                
                // Customer details
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: customer ? (customer.first_name + " " + customer.last_name) : "N/A"
                        font.pixelSize: 20
                        font.bold: true
                        color: themeManager.textColor
                    }
                    
                    RowLayout {
                        spacing: 16
                        
                        Text {
                            text: "📧 " + (customer ? customer.email || "No email" : "N/A")
                            color: themeManager.secondaryTextColor
                            font.pixelSize: 14
                        }
                        
                        Text {
                            text: "📞 " + (customer ? customer.phone || "No phone" : "N/A")
                            color: themeManager.secondaryTextColor
                            font.pixelSize: 14
                        }
                    }
                    
                    Text {
                        text: "📍 " + getFullAddress()
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 14
                        visible: getFullAddress() !== "No address"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Customer since " + (customer ? new Date(customer.created_at).toLocaleDateString() : "N/A")
                        color: themeManager.secondaryTextColor
                        font.pixelSize: 12
                    }
                }
                
                // Stats
                ColumnLayout {
                    spacing: 8
                    
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 60
                        color: themeManager.accentColor
                        radius: 8
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            Text {
                                text: "$" + (customer ? customer.total_purchases || 0 : 0).toFixed(2)
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Total Spent"
                                color: "white"
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Purchase history
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
                    text: "Purchase History"
                    font.pixelSize: 18
                    font.bold: true
                    color: themeManager.textColor
                }
                
                // Purchase list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    model: customerPurchases
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.02)
                        border.color: themeManager.dividerColor
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 16
                            
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: themeManager.primaryColor
                                radius: 20
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "🛒"
                                    font.pixelSize: 16
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Sale #" + (modelData.id || "N/A")
                                    font.bold: true
                                    color: themeManager.textColor
                                }
                                
                                Text {
                                    text: (modelData.items_count || 0) + " items"
                                    font.pixelSize: 12
                                    color: themeManager.secondaryTextColor
                                }
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                
                                Text {
                                    text: "$" + (modelData.total || 0).toFixed(2)
                                    font.bold: true
                                    color: themeManager.textColor
                                    Layout.alignment: Qt.AlignRight
                                }
                                
                                Text {
                                    text: new Date(modelData.created_at).toLocaleDateString()
                                    font.pixelSize: 12
                                    color: themeManager.secondaryTextColor
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: parent.count === 0
                        anchors.centerIn: parent
                        text: "No purchase history"
                        font.pixelSize: 14
                        color: themeManager.secondaryTextColor
                    }
                }
            }
        }
        
        // Notes section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: themeManager.surfaceColor
            border.color: themeManager.dividerColor
            border.width: 1
            radius: 8
            visible: customer && customer.notes
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 4
                
                Text {
                    text: "Notes"
                    font.pixelSize: 14
                    font.bold: true
                    color: themeManager.textColor
                }
                
                Text {
                    text: customer ? customer.notes || "" : ""
                    color: themeManager.secondaryTextColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    standardButtons: Dialog.Close
    
    function getFullAddress() {
        if (!customer) return "No address"
        
        var parts = []
        if (customer.address) parts.push(customer.address)
        if (customer.city) parts.push(customer.city)
        if (customer.state) parts.push(customer.state)
        if (customer.zip_code) parts.push(customer.zip_code)
        
        return parts.length > 0 ? parts.join(", ") : "No address"
    }
}
