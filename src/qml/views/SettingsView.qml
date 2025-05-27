import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"
import "../components"

Rectangle {
    id: root

    property bool isOnlineMode: true

    signal themeChanged(bool isDark)
    signal onlineModeToggled(bool enabled)

    color: Theme.backgroundColor

    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing * 2

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing * 2

            // Header
            Text {
                text: "Settings"
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.textColor
                Layout.fillWidth: true
            }

            // Appearance Section
            GroupBox {
                title: "Appearance"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacing

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Theme:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Row {
                            spacing: Theme.spacing

                            RadioButton {
                                id: lightThemeRadio
                                text: "Light"
                                checked: !Theme.isDarkMode
                                onClicked: {
                                    Theme.isDarkMode = false
                                    root.themeChanged(false)
                                }
                            }

                            RadioButton {
                                id: darkThemeRadio
                                text: "Dark"
                                checked: Theme.isDarkMode
                                onClicked: {
                                    Theme.isDarkMode = true
                                    root.themeChanged(true)
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Font Size:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Slider {
                            id: fontSizeSlider
                            from: 12
                            to: 20
                            value: Theme.fontSize
                            stepSize: 1
                            Layout.preferredWidth: 200

                            onValueChanged: {
                                // Update theme font size
                                console.log("Font size changed to:", value)
                            }
                        }

                        Text {
                            text: Math.round(fontSizeSlider.value) + "px"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColorSecondary
                            Layout.preferredWidth: 40
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Connection Section
            GroupBox {
                title: "Connection"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacing

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Mode:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Switch {
                            id: onlineModeSwitch
                            checked: root.isOnlineMode
                            onToggled: {
                                root.onlineModeToggled(checked)
                            }
                        }

                        Text {
                            text: onlineModeSwitch.checked ? "Online" : "Offline"
                            font.pixelSize: Theme.fontSize
                            color: onlineModeSwitch.checked ? Theme.successColor : Theme.warningColor
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Text {
                        text: "Online mode enables cloud synchronization and real-time features. Offline mode uses local data only."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textColorSecondary
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: !root.isOnlineMode

                        Text {
                            text: "Sync Status:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Text {
                            text: "Last synced: 2 hours ago"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColorSecondary
                        }

                        CustomButton {
                            text: "Sync Now"
                            primary: false
                            onClicked: console.log("Manual sync triggered")
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Database Section
            GroupBox {
                title: "Database"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacing

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Local Database:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Text {
                            text: "chaoffice.db (2.4 MB)"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColorSecondary
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing

                        CustomButton {
                            text: "Backup Database"
                            primary: false
                            onClicked: backupDialog.open()
                        }

                        CustomButton {
                            text: "Reset Database"
                            primary: false
                            onClicked: resetDialog.open()
                        }

                        CustomButton {
                            text: "Import Data"
                            primary: false
                            onClicked: console.log("Import data")
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Application Section
            GroupBox {
                title: "Application"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacing

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Auto-save:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Switch {
                            id: autoSaveSwitch
                            checked: true
                        }

                        Text {
                            text: autoSaveSwitch.checked ? "Enabled" : "Disabled"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColorSecondary
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Auto-sync interval:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        ComboBox {
                            model: ["5 minutes", "15 minutes", "30 minutes", "1 hour", "Manual only"]
                            currentIndex: 1
                            Layout.preferredWidth: 150
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Version:"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            Layout.preferredWidth: 120
                        }

                        Text {
                            text: "v0.1.0"
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColorSecondary
                        }

                        CustomButton {
                            text: "Check for Updates"
                            primary: false
                            enabled: root.isOnlineMode
                            onClicked: console.log("Check for updates")
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // About Section
            GroupBox {
                title: "About"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacing

                    Text {
                        text: "ChaOffice Core"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Bold
                        color: Theme.textColor
                    }

                    Text {
                        text: "A hybrid business management system built with PySide6 and QML. Supports both online and offline operations with automatic data synchronization."
                        font.pixelSize: Theme.fontSize
                        color: Theme.textColorSecondary
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing

                        CustomButton {
                            text: "Documentation"
                            primary: false
                            enabled: root.isOnlineMode
                            onClicked: console.log("Open documentation")
                        }

                        CustomButton {
                            text: "Support"
                            primary: false
                            enabled: root.isOnlineMode
                            onClicked: console.log("Open support")
                        }

                        CustomButton {
                            text: "Licenses"
                            primary: false
                            onClicked: licensesDialog.open()
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Backup Dialog
    MessagePopup {
        id: backupDialog
        title: "Backup Database"
        message: "Database backup will be created in the application folder. Continue?"
        type: "info"
        autoClose: false

        onAccepted: {
            console.log("Creating database backup...")
        }
    }

    // Reset Dialog
    MessagePopup {
        id: resetDialog
        title: "Reset Database"
        message: "This will delete all local data and reset the database to its initial state. This action cannot be undone. Are you sure?"
        type: "warning"
        autoClose: false

        onAccepted: {
            console.log("Resetting database...")
        }
    }

    // Licenses Dialog
    MessagePopup {
        id: licensesDialog
        title: "Third-Party Licenses"
        message: "This application uses the following open-source libraries:\n\n• PySide6 (LGPL)\n• SQLAlchemy (MIT)\n• Requests (Apache 2.0)\n• Loguru (MIT)\n• Python-JOSE (MIT)"
        type: "info"
        autoClose: false
    }
}
