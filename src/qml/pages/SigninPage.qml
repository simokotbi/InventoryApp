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
    title: "Sign In"
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
            text: "Sign In"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        Components.CustomInput {
            id: usernameInput
            label: "Username or Email"
            placeholderText: "Enter your username or email"
            Layout.fillWidth: true
            Layout.topMargin: Theme.defaultMargin
            onAccepted: passwordInput.forceActiveFocus()
        }

        Components.CustomInput {
            id: passwordInput
            label: "Password"
            placeholderText: "Enter your password"
            isPassword: true
            Layout.fillWidth: true
            onAccepted: loginButton.clicked()
        }

        Components.CustomButton {
            id: loginButton
            text: "Sign In"
            Layout.fillWidth: true
            Layout.topMargin: Theme.defaultMargin
            onClicked: {
                if (!usernameInput.text || !passwordInput.text) {
                    notification.show("Please fill in all fields", true)
                    return
                }
                const result = authHandler.login(usernameInput.text, passwordInput.text)
                if (!result.success) {
                    notification.show(result.message, true)
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.defaultMargin
            spacing: Theme.defaultSpacing

            Text {
                text: "Don't have an account?"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.textColor
            }

            Components.CustomButton {
                text: "Sign Up"
                outlined: true
                onClicked: {
                    var component = Qt.createComponent("SignupPage.qml")
                    if (component.status === Component.Ready) {
                        var signupWindow = component.createObject(null)
                        window.hide()
                        signupWindow.closed.connect(function() {
                            window.show()
                            usernameInput.text = ""
                            passwordInput.text = ""
                            usernameInput.forceActiveFocus()
                        })
                    } else if (component.status === Component.Error) {
                        notification.show("Error loading signup page: " + component.errorString(), true)
                    }
                }
            }
        }
    }

    Connections {
        target: authHandler
        function onLoginStatusChanged(success, message) {
            if (success) {
                notification.show(message, false)
                var component = Qt.createComponent("MainApplicationPage.qml")
                if (component.status === Component.Ready) {
                    var mainWindow = component.createObject(null)
                    window.close()
                } else if (component.status === Component.Error) {
                    notification.show("Error loading main page: " + component.errorString(), true)
                }
            }
        }
    }

    Component.onCompleted: {
        usernameInput.forceActiveFocus()
    }
}