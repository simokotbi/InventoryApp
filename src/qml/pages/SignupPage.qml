import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components"

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 600
    title: "Sign Up"
    color: Theme.backgroundColor

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

        CustomInput {
            id: usernameInput
            label: "Username"
            placeholderText: "Choose a username"
            Layout.fillWidth: true
            Layout.topMargin: Theme.defaultMargin
        }

        CustomInput {
            id: emailInput
            label: "Email"
            placeholderText: "Enter your email"
            Layout.fillWidth: true
        }

        CustomInput {
            id: passwordInput
            label: "Password"
            placeholderText: "Create a password"
            isPassword: true
            Layout.fillWidth: true
        }

        CustomInput {
            id: confirmPasswordInput
            label: "Confirm Password"
            placeholderText: "Confirm your password"
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

        CustomButton {
            text: "Sign Up"
            Layout.fillWidth: true
            Layout.topMargin: Theme.defaultMargin
            onClicked: {
                errorText.visible = false;
                
                // Basic validation
                if (!usernameInput.text || !emailInput.text || !passwordInput.text || !confirmPasswordInput.text) {
                    errorText.text = "All fields are required";
                    errorText.visible = true;
                    return;
                }
                
                if (passwordInput.text !== confirmPasswordInput.text) {
                    errorText.text = "Passwords do not match";
                    errorText.visible = true;
                    return;
                }

                const result = authHandler.register(usernameInput.text, emailInput.text, passwordInput.text);
                if (result.success) {
                    window.close();
                } else {
                    errorText.text = result.message;
                    errorText.visible = true;
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

            CustomButton {
                text: "Sign In"
                outlined: true
                onClicked: window.close()
            }
        }
    }
}