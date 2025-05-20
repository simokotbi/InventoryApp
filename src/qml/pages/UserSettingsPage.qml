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
    title: "User Settings"
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
            text: "User Settings"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
        }

        // Current User Info
        Rectangle {
            Layout.fillWidth: true
            height: userInfoColumn.height + (Theme.defaultPadding * 2)
            color: Qt.lighter(Theme.backgroundColor, 1.02)
            border.color: Qt.lighter(Theme.textColor, 1.8)
            border.width: 1
            radius: Theme.cornerRadius

            ColumnLayout {
                id: userInfoColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.defaultPadding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.defaultSpacing

                Text {
                    text: "Username: " + authHandler.currentUsername
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.textColor
                }

                Text {
                    text: "Email: " + authHandler.currentEmail
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.textColor
                }
            }
        }

        // Email Update Section
        GroupBox {
            Layout.fillWidth: true
            title: "Update Email"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.defaultSpacing

                Components.CustomInput {
                    id: newEmailInput
                    label: "New Email"
                    placeholderText: "Enter new email address"
                    Layout.fillWidth: true
                }

                Components.CustomButton {
                    text: "Update Email"
                    Layout.fillWidth: true
                    onClicked: {
                        if (!newEmailInput.text) {
                            notification.show("Please enter a new email address", true)
                            return
                        }
                        const result = authHandler.updateEmail(newEmailInput.text)
                        notification.show(result.message, !result.success)
                        if (result.success) {
                            newEmailInput.text = ""
                        }
                    }
                }
            }
        }

        // Password Update Section
        GroupBox {
            Layout.fillWidth: true
            title: "Update Password"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.defaultSpacing

                Components.CustomInput {
                    id: currentPasswordInput
                    label: "Current Password"
                    placeholderText: "Enter current password"
                    isPassword: true
                    Layout.fillWidth: true
                }

                Components.CustomInput {
                    id: newPasswordInput
                    label: "New Password"
                    placeholderText: "Enter new password"
                    isPassword: true
                    Layout.fillWidth: true
                }

                Components.CustomInput {
                    id: confirmPasswordInput
                    label: "Confirm New Password"
                    placeholderText: "Confirm new password"
                    isPassword: true
                    Layout.fillWidth: true
                }

                Components.CustomButton {
                    text: "Update Password"
                    Layout.fillWidth: true
                    onClicked: {
                        if (!currentPasswordInput.text || !newPasswordInput.text || !confirmPasswordInput.text) {
                            notification.show("Please fill in all password fields", true)
                            return
                        }
                        
                        if (newPasswordInput.text !== confirmPasswordInput.text) {
                            notification.show("New passwords do not match", true)
                            return
                        }

                        const result = authHandler.updatePassword(currentPasswordInput.text, newPasswordInput.text)
                        notification.show(result.message, !result.success)
                        if (result.success) {
                            currentPasswordInput.text = ""
                            newPasswordInput.text = ""
                            confirmPasswordInput.text = ""
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Theme.defaultSpacing

            Components.CustomButton {
                text: "Close"
                outlined: true
                onClicked: window.close()
            }
        }
    }

    Connections {
        target: authHandler
        function onSettingsUpdated(success, message) {
            notification.show(message, !success)
        }
        function onUserDataChanged(username, email) {
            // Force a re-render of the current user info
            window.update()
        }
    }
}