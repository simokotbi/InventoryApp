import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import Theme
import "../components" as Components

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 600
    title: "Sign Up"
    color: Theme.backgroundColor

    Material.theme: Material.Light
    Material.accent: Theme.primaryColor

    Components.NotificationPopup {
        id: notification
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: Theme.defaultSpacing * 2

        Text {
            text: "Create Account"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        Components.CustomInput {
            id: usernameInput
            label: "Username"
            placeholderText: "Choose a username"
            Layout.fillWidth: true
            Layout.topMargin: Theme.defaultMargin
            onAccepted: emailInput.forceActiveFocus()
        }

        Components.CustomInput {
            id: emailInput
            label: "Email"
            placeholderText: "Enter your email"
            Layout.fillWidth: true
            onAccepted: passwordInput.forceActiveFocus()
        }

        Components.CustomInput {
            id: passwordInput
            label: "Password"
            placeholderText: "Create a password"
            isPassword: true
            Layout.fillWidth: true
            onAccepted: confirmPasswordInput.forceActiveFocus()
        }

        Components.CustomInput {
            id: confirmPasswordInput
            label: "Confirm Password"
            placeholderText: "Confirm your password"
            isPassword: true
            Layout.fillWidth: true
            onAccepted: signupButton.clicked()
        }

        Components.CustomButton {
            id: signupButton
            text: "Sign Up"
            Layout.fillWidth: true
            Layout.topMargin: Theme.defaultMargin
            onClicked: {
                // Basic validation
                if (!usernameInput.text || !emailInput.text || !passwordInput.text || !confirmPasswordInput.text) {
                    notification.show("Please fill in all fields", true)
                    return
                }
                
                if (passwordInput.text !== confirmPasswordInput.text) {
                    notification.show("Passwords do not match", true)
                    return
                }

                if (passwordInput.text.length < 8) {
                    notification.show("Password must be at least 8 characters long", true)
                    return
                }

                if (!/[A-Z]/.test(passwordInput.text)) {
                    notification.show("Password must contain at least one uppercase letter", true)
                    return
                }

                if (!/[a-z]/.test(passwordInput.text)) {
                    notification.show("Password must contain at least one lowercase letter", true)
                    return
                }

                if (!/\d/.test(passwordInput.text)) {
                    notification.show("Password must contain at least one number", true)
                    return
                }

                if (!/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(emailInput.text)) {
                    notification.show("Please enter a valid email address", true)
                    return
                }

                const result = authHandler.register(usernameInput.text, emailInput.text, passwordInput.text)
                if (result.success) {
                    notification.show(result.message, false)
                    window.close()
                } else {
                    notification.show(result.message, true)
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.defaultMargin
            spacing: Theme.defaultSpacing

            Text {
                text: "Already have an account?"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.textColor
            }

            Components.CustomButton {
                text: "Sign In"
                outlined: true
                onClicked: window.close()
            }
        }
    }

    Component.onCompleted: {
        usernameInput.forceActiveFocus()
    }
}