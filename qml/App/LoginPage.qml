import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Themestyles 1.0
import Components 1.0

Page {
    id: loginPage
    title: "Login"

    signal loginRequested(string username, string password)

    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.mediumSpacing

        // Username Field
        InputField {
            id: usernameField
            placeholderText: "Username"
            
        }

        // Password Field
        InputField {
            id: passwordField
            placeholderText: "Password"
            echoMode: TextInput.Password
        }

        // ButtonPrimary for Login
        ButtonPrimary {
            text: "Login"  // Button text directly
            onClicked: {
                loginPage.loginRequested(usernameField.text, passwordField.text)
            }
            
        }

        // Error message label (if login fails)
        Label {
            id: errorLabel
            text: "Invalid credentials, please try again."
            color: Theme.errorColor
            font.family: Theme.fontFamily
            font.pointSize: Theme.captionSize
            visible: false
        }
    }
    Component.onCompleted: {
    // Handle login success and failure
    LoginManager.loginFailed.connect(function() {
        errorLabel.visible = true
    })
    LoginManager.loginSuccess.connect(function() {
        errorLabel.visible = false
    })

    // 🛠️ Connect the loginRequested signal to verify_login slot
    loginRequested.connect(LoginManager.verify_login)
}



}
