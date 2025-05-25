import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: customerDialog
    
    property bool isEdit: false
    property var customer: null
    property var customerData: ({
        first_name: firstNameField.text,
        last_name: lastNameField.text,
        email: emailField.text,
        phone: phoneField.text,
        address: addressField.text,
        city: cityField.text,
        state: stateField.text,
        zip_code: zipField.text,
        notes: notesField.text
    })
    
    title: isEdit ? "Edit Customer" : "Add Customer"
    modal: true
    anchors.centerIn: parent
    width: 500
    height: 600
    
    Material.accent: themeManager.primaryColor
    
    // Reset form when dialog opens
    onOpened: {
        if (isEdit && customer) {
            firstNameField.text = customer.first_name || ""
            lastNameField.text = customer.last_name || ""
            emailField.text = customer.email || ""
            phoneField.text = customer.phone || ""
            addressField.text = customer.address || ""
            cityField.text = customer.city || ""
            stateField.text = customer.state || ""
            zipField.text = customer.zip_code || ""
            notesField.text = customer.notes || ""
        } else {
            // Reset form for new customer
            firstNameField.text = ""
            lastNameField.text = ""
            emailField.text = ""
            phoneField.text = ""
            addressField.text = ""
            cityField.text = ""
            stateField.text = ""
            zipField.text = ""
            notesField.text = ""
        }
    }
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            // Name fields
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "First Name *"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: firstNameField
                        Layout.fillWidth: true
                        placeholderText: "Enter first name"
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Last Name *"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: lastNameField
                        Layout.fillWidth: true
                        placeholderText: "Enter last name"
                        Material.accent: themeManager.primaryColor
                    }
                }
            }
            
            // Contact information
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Email"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                TextField {
                    id: emailField
                    Layout.fillWidth: true
                    placeholderText: "Enter email address"
                    Material.accent: themeManager.primaryColor
                    validator: RegExpValidator { 
                        regExp: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Phone"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                TextField {
                    id: phoneField
                    Layout.fillWidth: true
                    placeholderText: "Enter phone number"
                    Material.accent: themeManager.primaryColor
                }
            }
            
            // Address
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Address"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                TextField {
                    id: addressField
                    Layout.fillWidth: true
                    placeholderText: "Enter street address"
                    Material.accent: themeManager.primaryColor
                }
            }
            
            // City, State, ZIP
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "City"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: cityField
                        Layout.fillWidth: true
                        placeholderText: "Enter city"
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.preferredWidth: 100
                    spacing: 4
                    
                    Text {
                        text: "State"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: stateField
                        Layout.fillWidth: true
                        placeholderText: "State"
                        Material.accent: themeManager.primaryColor
                    }
                }
                
                ColumnLayout {
                    Layout.preferredWidth: 120
                    spacing: 4
                    
                    Text {
                        text: "ZIP Code"
                        color: themeManager.textColor
                        font.bold: true
                    }
                    
                    TextField {
                        id: zipField
                        Layout.fillWidth: true
                        placeholderText: "ZIP"
                        Material.accent: themeManager.primaryColor
                    }
                }
            }
            
            // Notes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Notes"
                    color: themeManager.textColor
                    font.bold: true
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    TextArea {
                        id: notesField
                        placeholderText: "Enter any additional notes about the customer"
                        Material.accent: themeManager.primaryColor
                        wrapMode: TextArea.Wrap
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    // Validation
    property bool isValid: firstNameField.text.trim() !== "" && 
                          lastNameField.text.trim() !== ""
    
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
            onClicked: customerDialog.reject()
        }
        
        Button {
            text: customerDialog.isEdit ? "Update" : "Add"
            enabled: customerDialog.isValid
            Material.background: themeManager.primaryColor
            Material.foreground: "white"
            onClicked: customerDialog.accept()
        }
    }
    
    // Validation error dialog
    MessagePopup {
        id: validationError
        title: "Validation Error"
        message: "Please fill in all required fields (First Name, Last Name)"
        type: "error"
    }
}
