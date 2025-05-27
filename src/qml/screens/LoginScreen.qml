import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"
import "../components"

Rectangle {
    id: root
    
    signal loginRequested(string email, string password)
    signal offlineModeRequested()
    
    property bool isLoading: false
    property string errorMessage: ""
    
    color: Theme.backgroundColor
    
    // Background pattern
    Rectangle {
        anchors.fill: parent
        color: Theme.primaryColor
        opacity: 0.05
        
        // Subtle pattern
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = Theme.primaryColor
                ctx.lineWidth = 1
                ctx.globalAlpha = 0.1
                
                var spacing = 50
                for (var x = 0; x <= width; x += spacing) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                for (var y = 0; y <= height; y += spacing) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
        }
        }
    }
    
    // Main content
    Rectangle {
        width: Math.min(400, parent.width * 0.9)
        height: Math.min(600, parent.height * 0.9)
        anchors.centerIn: parent
        color: Theme.backgroundColor
        radius: Theme.cardRadius
        border.color: Theme.borderColor
        border.width: 1
        
        // Simple shadow effect using multiple rectangles
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 4
            color: "#20000000"
            radius: parent.radius
            z: -1
        }
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#10000000"
            radius: parent.radius
            z: -2
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacing * 2
            spacing: Theme.spacing * 1.5
            
            // Header
            Column {
                spacing: Theme.spacingSmall
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    width: 80
                    height: 80
                    radius: 40
                    color: Theme.primaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Text {
                        anchors.centerIn: parent
                        text: "CO"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: "white"
                    }
                }
                
                Text {
                    text: "ChaOffice"
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Font.Bold
                    color: Theme.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Sign in to your account"
                    font.pixelSize: Theme.fontSize
                    color: Theme.textColorSecondary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            // Login form
            Column {
                spacing: Theme.spacing
                width: parent.width
                
                CustomInput {
                    id: emailInput
                    width: parent.width
                    placeholderText: "Email address"
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    enabled: !root.isLoading
                    
                    KeyNavigation.tab: passwordInput
                    
                    onAccepted: {
                        if (passwordInput.text.length > 0) {
                            loginButton.clicked()
                        } else {
                            passwordInput.forceActiveFocus()
                        }
                    }
                }
                
                CustomInput {
                    id: passwordInput
                    width: parent.width
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    enabled: !root.isLoading
                    
                    KeyNavigation.tab: loginButton
                    
                    onAccepted: loginButton.clicked()
                }
                
                // Error message
                Text {
                    text: root.errorMessage
                    color: Theme.errorColor
                    font.pixelSize: Theme.fontSizeSmall
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: root.errorMessage !== ""
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -Theme.spacingSmall
                        color: Theme.errorColor
                        opacity: 0.1
                        radius: 4
                        visible: parent.visible
                    }
                }
                
                CustomButton {                    id: loginButton
                    text: root.isLoading ? "Signing in..." : "Sign In"
                    width: parent.width
                    variant: "primary"
                    enabled: !root.isLoading && emailInput.text.length > 0 && passwordInput.text.length > 0
                    
                    onClicked: {
                        root.errorMessage = ""
                        root.loginRequested(emailInput.text, passwordInput.text)
                    }
                    
                    // Loading indicator
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.isLoading
                        
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: "white"
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 1
                        }
                        
                        RotationAnimation on rotation {
                            running: root.isLoading
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 1000
                        }
                    }
                }
            }
              // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.borderColor
                
                Rectangle {
                    anchors.centerIn: parent
                    color: Theme.backgroundColor
                    width: orText.width + Theme.spacing
                    height: orText.height + Theme.spacingSmall
                    
                    Text {
                        id: orText
                        anchors.centerIn: parent
                        text: "OR"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textColorSecondary
                    }
                }
            }
            
            // Offline mode
            CustomButton {                text: "Continue Offline"
                width: parent.width
                variant: "secondary"
                enabled: !root.isLoading
                
                onClicked: root.offlineModeRequested()
            }
            
            // Footer
            Text {
                text: "Offline mode uses local data only.\nOnline features will be disabled."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textColorSecondary
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }
    
    function clearForm() {
        emailInput.text = ""
        passwordInput.text = ""
        root.errorMessage = ""
    }
    
    function focusEmail() {
        emailInput.forceActiveFocus()
    }
}
