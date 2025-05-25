import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
// import BusinessApp 1.0  // Temporarily disabled

Item {
    id: loginScreen
    
    signal loginSuccess()
      Rectangle {
        anchors.fill: parent
        color: themeManager.backgroundColor
        
        // Split layout: Left side branding, Right side login form
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            // Left side - Branding
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.4
                color: themeManager.primaryColor
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: themeManager.spacingLarge
                    
                    // Logo
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 50
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: "CHA"
                            font.pixelSize: 28
                            font.bold: true
                            color: themeManager.primaryColor
                        }
                    }
                    
                    Text {
                        text: "ChaOffice"
                        font.pixelSize: themeManager.xlargeFontSize
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Business Management Solution"
                        font.pixelSize: themeManager.mediumFontSize
                        color: "white"
                        opacity: 0.8
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    ColumnLayout {
                        spacing: themeManager.spacing
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: themeManager.spacingLarge
                        
                        Text {
                            text: "✓ Point of Sale System"
                            color: "white"
                            font.pixelSize: themeManager.normalFontSize
                        }
                        Text {
                            text: "✓ Inventory Management"
                            color: "white"
                            font.pixelSize: themeManager.normalFontSize
                        }
                        Text {
                            text: "✓ Customer Management"
                            color: "white"
                            font.pixelSize: themeManager.normalFontSize
                        }
                        Text {
                            text: "✓ Sales Reports & Analytics"
                            color: "white"
                            font.pixelSize: themeManager.normalFontSize
                        }
                    }
                }
            }
            
            // Right side - Login form
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: themeManager.surfaceColor
                
                ScrollView {
                    anchors.fill: parent
                    contentHeight: loginForm.height + themeManager.spacingXLarge * 2
                    
                    ColumnLayout {
                        id: loginForm
                        anchors.centerIn: parent
                        width: Math.min(400, parent.width - themeManager.spacingXLarge * 2)
                        spacing: themeManager.spacingMedium
                        
                        // Header
                        Text {
                            text: "Welcome Back"
                            font.pixelSize: themeManager.xlargeFontSize
                            font.bold: true
                            color: themeManager.textPrimaryColor
                            Layout.alignment: Qt.AlignHCenter
                            Layout.bottomMargin: themeManager.spacing
                        }
                        
                        Text {
                            text: "Sign in to your account"
                            font.pixelSize: themeManager.mediumFontSize
                            color: themeManager.textSecondaryColor
                            Layout.alignment: Qt.AlignHCenter
                            Layout.bottomMargin: themeManager.spacingLarge
                        }
                        
                        // Username field
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: themeManager.spacingSmall
                            
                            Text {
                                text: "Username or Email"
                                color: themeManager.textPrimaryColor
                                font.pixelSize: themeManager.normalFontSize
                            }
                            
                            TextField {
                                id: usernameField
                                Layout.fillWidth: true
                                placeholderText: "Enter your username or email"
                                selectByMouse: true
                                
                                background: Rectangle {
                                    color: themeManager.backgroundColor
                                    border.color: usernameField.activeFocus ? themeManager.primaryColor : themeManager.borderColor
                                    border.width: 1
                                    radius: themeManager.cornerRadius
                                }
                                
                                Keys.onReturnPressed: passwordField.forceActiveFocus()
                            }
                        }
                        
                        // Password field
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: themeManager.spacingSmall
                            
                            Text {
                                text: "Password"
                                color: themeManager.textPrimaryColor
                                font.pixelSize: themeManager.normalFontSize
                            }
                            
                            TextField {
                                id: passwordField
                                Layout.fillWidth: true
                                placeholderText: "Enter your password"
                                echoMode: TextInput.Password
                                selectByMouse: true
                                
                                background: Rectangle {
                                    color: themeManager.backgroundColor
                                    border.color: passwordField.activeFocus ? themeManager.primaryColor : themeManager.borderColor
                                    border.width: 1
                                    radius: themeManager.cornerRadius
                                }
                                
                                Keys.onReturnPressed: loginButton.clicked()
                            }
                        }
                        
                        // Remember me checkbox
                        CheckBox {
                            id: rememberMeCheck
                            text: "Remember me"
                            Layout.topMargin: themeManager.spacing
                            
                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: rememberMeCheck.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: rememberMeCheck.checked ? themeManager.primaryColor : themeManager.borderColor
                                color: rememberMeCheck.checked ? themeManager.primaryColor : "transparent"
                                
                                Text {
                                    text: "✓"
                                    color: "white"
                                    anchors.centerIn: parent
                                    visible: rememberMeCheck.checked
                                    font.pixelSize: 14
                                }
                            }
                        }
                        
                        // Login button
                        Button {
                            id: loginButton
                            text: "Sign In"
                            Layout.fillWidth: true
                            Layout.topMargin: themeManager.spacingMedium
                            enabled: usernameField.text.length > 0 && passwordField.text.length > 0 && !isLoggingIn
                            
                            property bool isLoggingIn: false
                            
                            background: Rectangle {
                                color: loginButton.enabled ? 
                                    (loginButton.pressed ? themeManager.primaryDarkColor : themeManager.primaryColor) : 
                                    themeManager.borderColor
                                radius: themeManager.cornerRadius
                                
                                Behavior on color {
                                    ColorAnimation { duration: themeManager.animationDurationShort }
                                }
                            }
                            
                            contentItem: RowLayout {
                                spacing: themeManager.spacing
                                
                                BusyIndicator {
                                    visible: loginButton.isLoggingIn
                                    running: loginButton.isLoggingIn
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                }
                                
                                Text {
                                    text: loginButton.isLoggingIn ? "Signing In..." : "Sign In"
                                    color: "white"
                                    font.pixelSize: themeManager.mediumFontSize
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                            
                            onClicked: {
                                if (usernameField.text.length === 0) {
                                    showMessage("Please enter your username or email", "error")
                                    return
                                }
                                
                                if (passwordField.text.length === 0) {
                                    showMessage("Please enter your password", "error")
                                    return
                                }
                                
                                isLoggingIn = true
                                
                                var result = authHandler.login(
                                    usernameField.text,
                                    passwordField.text,
                                    rememberMeCheck.checked
                                )
                                
                                if (result.success) {
                                    showMessage("Login successful! Welcome back.", "success")
                                    loginScreen.loginSuccess()
                                } else {
                                    showMessage(result.message || "Login failed", "error")
                                }
                                
                                isLoggingIn = false
                            }
                        }
                        
                        // Divider
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: themeManager.dividerColor
                            Layout.topMargin: themeManager.spacingMedium
                            Layout.bottomMargin: themeManager.spacingMedium
                        }
                        
                        // Demo credentials info
                        Rectangle {
                            Layout.fillWidth: true
                            color: themeManager.infoColor
                            opacity: 0.1
                            radius: themeManager.cornerRadius
                            height: demoInfo.height + themeManager.spacingMedium
                            
                            ColumnLayout {
                                id: demoInfo
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: themeManager.spacingMedium
                                spacing: themeManager.spacingSmall
                                
                                Text {
                                    text: "Demo Credentials:"
                                    color: themeManager.infoColor
                                    font.pixelSize: themeManager.normalFontSize
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "Admin: admin@chaoffice.com / admin123"
                                    color: themeManager.textSecondaryColor
                                    font.pixelSize: themeManager.smallFontSize
                                }
                                
                                Text {
                                    text: "Manager: manager@chaoffice.com / manager123"
                                    color: themeManager.textSecondaryColor
                                    font.pixelSize: themeManager.smallFontSize
                                }
                                
                                Text {
                                    text: "Employee: employee@chaoffice.com / employee123"
                                    color: themeManager.textSecondaryColor
                                    font.pixelSize: themeManager.smallFontSize
                                }
                            }
                        }
                        
                        // Theme toggle
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: themeManager.spacingMedium
                            
                            Text {
                                text: "Theme:"
                                color: themeManager.textSecondaryColor
                                font.pixelSize: themeManager.normalFontSize
                            }
                            
                            Button {
                                text: themeManager.currentTheme === "light" ? "🌙 Dark" : "☀️ Light"
                                flat: true
                                
                                onClicked: themeManager.toggleTheme()
                                
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: themeManager.borderColor
                                    border.width: 1
                                    radius: themeManager.cornerRadius
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Message notification
    function showMessage(message, type) {
        messagePopup.show(message, type)
    }
    
    // Message popup
    MessagePopup {
        id: messagePopup
        anchors.centerIn: parent
    }
}
