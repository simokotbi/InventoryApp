import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components"

Window {
    id: window
    width: 500
    height: 500
    title: "User Settings"
    color: Theme.backgroundColor
    flags: Qt.Dialog
    modality: Qt.ApplicationModal

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

        CustomInput {
            id: emailInput
            label: "Email"
            placeholderText: "Enter new email"
            Layout.fillWidth: true
        }

        CustomInput {
            id: currentPasswordInput
            label: "Current Password"
            placeholderText: "Enter current password"
            isPassword: true
            Layout.fillWidth: true
        }

        CustomInput {
            id: newPasswordInput
            label: "New Password"
            placeholderText: "Enter new password"
            isPassword: true
            Layout.fillWidth: true
        }

        CustomInput {
            id: confirmPasswordInput
            label: "Confirm New Password"
            placeholderText: "Confirm new password"
            isPassword: true
            Layout.fillWidth: true
        }

        Text {
            id: errorText
            visible: false
            color: Theme.errorColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Text {
            id: successText
            visible: false
            color: Theme.successColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Theme.defaultSpacing

            CustomButton {
                text: "Cancel"
                outlined: true
                onClicked: window.close()
            }

            CustomButton {
                text: "Save Changes"
                onClicked: {
                    errorText.visible = false;
                    successText.visible = false;

                    if (newPasswordInput.text || confirmPasswordInput.text) {
                        if (!currentPasswordInput.text) {
                            errorText.text = "Current password is required";
                            errorText.visible = true;
                            return;
                        }
                        if (newPasswordInput.text !== confirmPasswordInput.text) {
                            errorText.text = "New passwords do not match";
                            errorText.visible = true;
                            return;
                        }
                    }

                    // TODO: Implement actual password change logic through Python backend
                    successText.text = "Settings updated successfully";
                    successText.visible = true;
                }
            }
        }
    }
}