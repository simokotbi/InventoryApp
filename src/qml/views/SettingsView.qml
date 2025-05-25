import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Item {
    id: settingsView
    
    property var settings: settingsHandler.settings || {}
    property bool isLoading: settingsHandler.isLoading
    
    Component.onCompleted: {
        settingsHandler.loadSettings()
    }
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 24
            
            // Header
            Text {
                text: "Settings"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.textColor
                Layout.fillWidth: true
            }
            
            // Business Information
            GroupBox {
                Layout.fillWidth: true
                title: "Business Information"
                Material.accent: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Business Name *"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            TextField {
                                id: businessNameField
                                Layout.fillWidth: true
                                text: settings.business_name || ""
                                placeholderText: "Enter business name"
                                Material.accent: themeManager.primaryColor
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Business Type"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: businessTypeCombo
                                Layout.fillWidth: true
                                model: ["Retail", "Restaurant", "Service", "Wholesale", "Other"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.business_type || "Retail")
                                }
                            }
                        }
                    }
                    
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
                            text: settings.business_address || ""
                            placeholderText: "Enter business address"
                            Material.accent: themeManager.primaryColor
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
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
                                text: settings.business_phone || ""
                                placeholderText: "(555) 123-4567"
                                Material.accent: themeManager.primaryColor
                            }
                        }
                        
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
                                text: settings.business_email || ""
                                placeholderText: "business@example.com"
                                Material.accent: themeManager.primaryColor
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Tax ID"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            TextField {
                                id: taxIdField
                                Layout.fillWidth: true
                                text: settings.tax_id || ""
                                placeholderText: "Tax ID number"
                                Material.accent: themeManager.primaryColor
                            }
                        }
                    }
                }
            }
            
            // Sales & POS Settings
            GroupBox {
                Layout.fillWidth: true
                title: "Sales & POS Settings"
                Material.accent: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Default Tax Rate (%)"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            TextField {
                                id: taxRateField
                                Layout.fillWidth: true
                                text: (settings.default_tax_rate || 0).toString()
                                placeholderText: "0.00"
                                validator: DoubleValidator { bottom: 0; top: 100; decimals: 2 }
                                Material.accent: themeManager.primaryColor
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Currency"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: currencyCombo
                                Layout.fillWidth: true
                                model: ["USD ($)", "EUR (€)", "GBP (£)", "CAD ($)", "AUD ($)"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.currency || "USD ($)")
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Receipt Printer"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: printerCombo
                                Layout.fillWidth: true
                                model: ["Default Printer", "PDF Export", "Email Only", "No Printing"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.receipt_printer || "Default Printer")
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: autoReceiptCheck
                            text: "Auto-print receipts"
                            checked: settings.auto_print_receipt === true
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: showStockCheck
                            text: "Show stock levels in POS"
                            checked: settings.show_stock_in_pos === true
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: lowStockWarningCheck
                            text: "Low stock warnings"
                            checked: settings.low_stock_warnings === true
                            Material.accent: themeManager.primaryColor
                        }
                    }
                }
            }
            
            // Inventory Settings
            GroupBox {
                Layout.fillWidth: true
                title: "Inventory Settings"
                Material.accent: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Default Low Stock Threshold"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            TextField {
                                id: lowStockThresholdField
                                Layout.fillWidth: true
                                text: (settings.default_low_stock_threshold || 10).toString()
                                placeholderText: "10"
                                validator: IntValidator { bottom: 0 }
                                Material.accent: themeManager.primaryColor
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Inventory Valuation Method"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: valuationMethodCombo
                                Layout.fillWidth: true
                                model: ["FIFO", "LIFO", "Average Cost", "Standard Cost"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.inventory_valuation || "FIFO")
                                }
                            }
                        }
                        
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: trackSerialCheck
                            text: "Track serial numbers"
                            checked: settings.track_serial_numbers === true
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: autoReorderCheck
                            text: "Auto-reorder notifications"
                            checked: settings.auto_reorder_notifications === true
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: barcodeCheck
                            text: "Use barcode scanning"
                            checked: settings.use_barcode_scanning === true
                            Material.accent: themeManager.primaryColor
                        }
                    }
                }
            }
            
            // Data & Sync Settings
            GroupBox {
                Layout.fillWidth: true
                title: "Data & Synchronization"
                Material.accent: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Sync Mode"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: syncModeCombo
                                Layout.fillWidth: true
                                model: ["Offline Only", "Auto Sync", "Manual Sync"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.sync_mode || "Auto Sync")
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Sync Interval (minutes)"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            TextField {
                                id: syncIntervalField
                                Layout.fillWidth: true
                                text: (settings.sync_interval || 15).toString()
                                placeholderText: "15"
                                validator: IntValidator { bottom: 1; top: 1440 }
                                Material.accent: themeManager.primaryColor
                                enabled: syncModeCombo.currentText === "Auto Sync"
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Backup Frequency"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: backupFrequencyCombo
                                Layout.fillWidth: true
                                model: ["Daily", "Weekly", "Monthly", "Never"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.backup_frequency || "Daily")
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Button {
                            text: "Sync Now"
                            Material.background: themeManager.primaryColor
                            Material.foreground: "white"
                            onClicked: syncHandler.syncNow()
                        }
                        
                        Button {
                            text: "Backup Data"
                            flat: true
                            Material.foreground: themeManager.accentColor
                            onClicked: settingsHandler.backupData()
                        }
                        
                        Button {
                            text: "Export Data"
                            flat: true
                            Material.foreground: themeManager.primaryColor
                            onClicked: exportDialog.open()
                        }
                        
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }
            }
            
            // User Interface Settings
            GroupBox {
                Layout.fillWidth: true
                title: "User Interface"
                Material.accent: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Theme"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: themeCombo
                                Layout.fillWidth: true
                                model: ["Light", "Dark", "Auto"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.theme || "Light")
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Language"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: languageCombo
                                Layout.fillWidth: true
                                model: ["English", "Spanish", "French", "German", "Chinese"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.language || "English")
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Date Format"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: dateFormatCombo
                                Layout.fillWidth: true
                                model: ["MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.date_format || "MM/DD/YYYY")
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: compactModeCheck
                            text: "Compact mode"
                            checked: settings.compact_mode === true
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: animationsCheck
                            text: "Enable animations"
                            checked: settings.enable_animations !== false
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: notificationsCheck
                            text: "Show notifications"
                            checked: settings.show_notifications !== false
                            Material.accent: themeManager.primaryColor
                        }
                    }
                }
            }
            
            // Security Settings
            GroupBox {
                Layout.fillWidth: true
                title: "Security"
                Material.accent: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Session Timeout (minutes)"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            TextField {
                                id: sessionTimeoutField
                                Layout.fillWidth: true
                                text: (settings.session_timeout || 30).toString()
                                placeholderText: "30"
                                validator: IntValidator { bottom: 5; top: 480 }
                                Material.accent: themeManager.primaryColor
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: "Password Policy"
                                color: themeManager.textColor
                                font.bold: true
                            }
                            
                            ComboBox {
                                id: passwordPolicyCombo
                                Layout.fillWidth: true
                                model: ["Basic", "Strong", "Enterprise"]
                                Material.accent: themeManager.primaryColor
                                Component.onCompleted: {
                                    currentIndex = find(settings.password_policy || "Basic")
                                }
                            }
                        }
                        
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: twoFactorCheck
                            text: "Two-factor authentication"
                            checked: settings.enable_2fa === true
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: auditLogCheck
                            text: "Enable audit logging"
                            checked: settings.enable_audit_log !== false
                            Material.accent: themeManager.primaryColor
                        }
                        
                        CheckBox {
                            id: encryptDataCheck
                            text: "Encrypt local data"
                            checked: settings.encrypt_local_data === true
                            Material.accent: themeManager.primaryColor
                        }
                    }
                }
            }
            
            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                spacing: 16
                
                Button {
                    text: "Reset to Defaults"
                    flat: true
                    Material.foreground: themeManager.errorColor
                    onClicked: resetConfirmDialog.open()
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "Cancel"
                    flat: true
                    Material.foreground: themeManager.secondaryTextColor
                    onClicked: settingsHandler.loadSettings() // Reload original settings
                }
                
                Button {
                    text: "Save Settings"
                    Material.background: themeManager.primaryColor
                    Material.foreground: "white"
                    onClicked: saveSettings()
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    // Export data dialog
    Dialog {
        id: exportDialog
        title: "Export Data"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 300
        
        Material.accent: themeManager.primaryColor
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            
            Text {
                text: "Select data to export:"
                font.bold: true
                color: themeManager.textColor
            }
            
            CheckBox {
                text: "Products"
                checked: true
                Material.accent: themeManager.primaryColor
            }
            
            CheckBox {
                text: "Customers"
                checked: true
                Material.accent: themeManager.primaryColor
            }
            
            CheckBox {
                text: "Sales"
                checked: true
                Material.accent: themeManager.primaryColor
            }
            
            CheckBox {
                text: "Inventory"
                checked: true
                Material.accent: themeManager.primaryColor
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Text {
                    text: "Format:"
                    color: themeManager.textColor
                }
                
                ComboBox {
                    Layout.fillWidth: true
                    model: ["CSV", "Excel", "JSON"]
                    Material.accent: themeManager.primaryColor
                }
            }
        }
        
        standardButtons: Dialog.Ok | Dialog.Cancel
    }
    
    // Reset confirmation dialog
    MessagePopup {
        id: resetConfirmDialog
        title: "Reset Settings"
        message: "Are you sure you want to reset all settings to their default values? This action cannot be undone."
        type: "warning"
        
        onAccepted: {
            settingsHandler.resetToDefaults()
        }
    }
    
    // Success message
    MessagePopup {
        id: successMessage
        title: "Settings Saved"
        message: "Your settings have been saved successfully."
        type: "success"
    }
    
    // Functions
    function saveSettings() {
        var settingsData = {
            business_name: businessNameField.text,
            business_type: businessTypeCombo.currentText,
            business_address: addressField.text,
            business_phone: phoneField.text,
            business_email: emailField.text,
            tax_id: taxIdField.text,
            default_tax_rate: parseFloat(taxRateField.text) || 0,
            currency: currencyCombo.currentText,
            receipt_printer: printerCombo.currentText,
            auto_print_receipt: autoReceiptCheck.checked,
            show_stock_in_pos: showStockCheck.checked,
            low_stock_warnings: lowStockWarningCheck.checked,
            default_low_stock_threshold: parseInt(lowStockThresholdField.text) || 10,
            inventory_valuation: valuationMethodCombo.currentText,
            track_serial_numbers: trackSerialCheck.checked,
            auto_reorder_notifications: autoReorderCheck.checked,
            use_barcode_scanning: barcodeCheck.checked,
            sync_mode: syncModeCombo.currentText,
            sync_interval: parseInt(syncIntervalField.text) || 15,
            backup_frequency: backupFrequencyCombo.currentText,
            theme: themeCombo.currentText,
            language: languageCombo.currentText,
            date_format: dateFormatCombo.currentText,
            compact_mode: compactModeCheck.checked,
            enable_animations: animationsCheck.checked,
            show_notifications: notificationsCheck.checked,
            session_timeout: parseInt(sessionTimeoutField.text) || 30,
            password_policy: passwordPolicyCombo.currentText,
            enable_2fa: twoFactorCheck.checked,
            enable_audit_log: auditLogCheck.checked,
            encrypt_local_data: encryptDataCheck.checked
        }
        
        settingsHandler.saveSettings(settingsData)
        successMessage.open()
    }
}
