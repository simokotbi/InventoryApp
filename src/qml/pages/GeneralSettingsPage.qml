import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import Theme
import "../components" as Components

Window {
    id: window
    width: 500
    height: 500
    title: "Application Settings"
    color: Theme.backgroundColor
    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    Material.theme: Material.Light
    Material.accent: Theme.primaryColor

    Components.NotificationPopup {
        id: notification
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.defaultMargin
        spacing: Theme.defaultSpacing * 2

        Text {
            text: "Application Settings"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
        }

        GroupBox {
            title: "Theme Settings"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.defaultSpacing

                // Theme Mode Toggle
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "Dark Mode"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textColor
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: darkModeSwitch
                        checked: settingsHandler.darkMode
                        onCheckedChanged: settingsHandler.darkMode = checked
                    }
                }

                // Primary Color Selection
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "Primary Color"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textColor
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        id: primaryColorCombo
                        model: ["Blue", "Green", "Purple", "Orange"]
                        Component.onCompleted: currentIndex = model.indexOf(settingsHandler.getCurrentColorName())
                        onCurrentTextChanged: settingsHandler.setPrimaryColorByName(currentText)
                    }
                }

                // Font Selection
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "Font Family"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textColor
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        id: fontFamilyCombo
                        model: ["Segoe UI", "Arial", "Roboto", "Open Sans"]
                        Component.onCompleted: currentIndex = model.indexOf(settingsHandler.fontFamily)
                        onCurrentTextChanged: settingsHandler.fontFamily = currentText
                    }
                }
            }
        }

        GroupBox {
            title: "Security Settings"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.defaultSpacing

                // Auto Logout Timer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "Auto Logout (minutes)"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textColor
                        Layout.fillWidth: true
                    }

                    SpinBox {
                        id: autoLogoutSpinner
                        from: 0
                        to: 120
                        value: settingsHandler.autoLogout
                        stepSize: 5
                        onValueChanged: settingsHandler.autoLogout = value
                    }
                }

                // Session Timeout
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "Session Timeout (hours)"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textColor
                        Layout.fillWidth: true
                    }

                    SpinBox {
                        id: sessionTimeoutSpinner
                        from: 1
                        to: 72
                        value: settingsHandler.sessionTimeout
                        onValueChanged: settingsHandler.sessionTimeout = value
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Theme.defaultSpacing

            Components.CustomButton {
                text: "Restore Defaults"
                outlined: true
                onClicked: {
                    if (settingsHandler.restoreDefaults()) {
                        notification.show("Settings restored to defaults", false);
                    }
                }
            }

            Components.CustomButton {
                text: "Close"
                outlined: true
                onClicked: window.close()
            }
        }
    }

    Connections {
        target: settingsHandler
        function onSettingsChanged() {
            // Update UI when settings change externally
            darkModeSwitch.checked = settingsHandler.darkMode;
            primaryColorCombo.currentIndex = primaryColorCombo.model.indexOf(settingsHandler.getCurrentColorName());
            fontFamilyCombo.currentIndex = fontFamilyCombo.model.indexOf(settingsHandler.fontFamily);
            autoLogoutSpinner.value = settingsHandler.autoLogout;
            sessionTimeoutSpinner.value = settingsHandler.sessionTimeout;
        }
    }
}