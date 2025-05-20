import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import Theme
import "../components" as Components
import "../views" as Views

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "Application"
    color: Theme.backgroundColor

    Material.theme: settingsHandler.darkMode ? Material.Dark : Material.Light
    Material.accent: settingsHandler.primaryColor

    Components.NotificationPopup {
        id: notification
    }

    Components.SessionManager {
        id: sessionManager
    }

    // Activity Monitor for session management
    HoverHandler {
        id: hoverHandler
        onHoveredChanged: if (enabled) sessionManager.resetActivityTimer()
    }

    TapHandler {
        id: tapHandler
        onTapped: sessionManager.resetActivityTimer()
    }

    header: Rectangle {
        height: 60
        color: Theme.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.defaultMargin

            Text {
                text: "My Application"
                color: "white"
                font {
                    family: settingsHandler.fontFamily
                    pixelSize: Theme.fontSizeLarge
                    bold: true
                }
                Layout.alignment: Qt.AlignLeft
            }

            Item { Layout.fillWidth: true }

            Text {
                text: authHandler.currentUsername
                color: "white"
                font {
                    family: settingsHandler.fontFamily
                    pixelSize: Theme.fontSizeMedium
                }
            }

            Components.CustomButton {
                text: "User Settings"
                secondary: true
                outlined: true
                onClicked: {
                    sessionManager.resetActivityTimer()
                    var component = Qt.createComponent("UserSettingsPage.qml")
                    if (component.status === Component.Ready) {
                        var settingsWindow = component.createObject(window)
                        settingsWindow.show()
                    } else if (component.status === Component.Error) {
                        notification.show("Error loading settings: " + component.errorString(), true)
                    }
                }
            }

            Components.CustomButton {
                text: "Logout"
                secondary: true
                onClicked: {
                    authHandler.logout()
                    window.close()
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            id: sidebar
            Layout.preferredWidth: sidebarExpanded ? 200 : 50
            Layout.fillHeight: true
            color: Qt.darker(Theme.backgroundColor, 1.05)

            property bool sidebarExpanded: true

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Toggle button
                Components.CustomButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: sidebar.sidebarExpanded ? "◄" : "►"
                    onClicked: sidebar.sidebarExpanded = !sidebar.sidebarExpanded
                }

                Repeater {
                    model: [{text: "Dashboard", icon: "◈"}, 
                           {text: "Analytics", icon: "◉"}, 
                           {text: "User Form", icon: "⬚"}]
                    delegate: ItemDelegate {
                        Layout.fillWidth: true
                        height: 48
                        highlighted: contentStack.currentIndex === index

                        contentItem: RowLayout {
                            spacing: Theme.defaultSpacing

                            Text {
                                text: modelData.icon
                                color: parent.parent.highlighted ? Theme.primaryColor : Theme.textColor
                                font.pixelSize: Theme.fontSizeLarge
                                visible: !sidebar.sidebarExpanded
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: modelData.text
                                color: parent.parent.highlighted ? Theme.primaryColor : Theme.textColor
                                font.family: settingsHandler.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                visible: sidebar.sidebarExpanded
                                Layout.fillWidth: true
                                leftPadding: Theme.defaultPadding
                            }
                        }

                        background: Rectangle {
                            color: parent.highlighted ? Qt.lighter(Theme.backgroundColor, 1.02) : "transparent"
                        }

                        ToolTip.visible: !sidebar.sidebarExpanded && hovered
                        ToolTip.text: modelData.text
                        ToolTip.delay: 500

                        onClicked: {
                            sessionManager.resetActivityTimer()
                            contentStack.currentIndex = index
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                ItemDelegate {
                    Layout.fillWidth: true
                    height: 48

                    contentItem: RowLayout {
                        spacing: Theme.defaultSpacing

                        Text {
                            text: "⚙"
                            color: Theme.textColor
                            font.pixelSize: Theme.fontSizeLarge
                            visible: !sidebar.sidebarExpanded
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Settings"
                            color: Theme.textColor
                            font.family: settingsHandler.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            visible: sidebar.sidebarExpanded
                            Layout.fillWidth: true
                            leftPadding: Theme.defaultPadding
                        }
                    }

                    ToolTip.visible: !sidebar.sidebarExpanded && hovered
                    ToolTip.text: "Settings"
                    ToolTip.delay: 500

                    onClicked: {
                        sessionManager.resetActivityTimer()
                        var component = Qt.createComponent("GeneralSettingsPage.qml")
                        if (component.status === Component.Ready) {
                            var settingsWindow = component.createObject(window)
                            settingsWindow.show()
                        } else if (component.status === Component.Error) {
                            notification.show("Error loading settings: " + component.errorString(), true)
                        }
                    }
                }
            }
        }

        // Main Content Area
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            Views.DashboardView {}
            Views.AnalyticsView {}
            Views.UserFormView {
                onFormSubmitted: (formData) => {
                    sessionManager.resetActivityTimer()
                    notification.show("Form submitted successfully!", false)
                }
            }
        }
    }

    Connections {
        target: authHandler
        function onUserDataChanged(username, email) {
            notification.show("Welcome back, " + username + "!", false)
            sessionManager.resetSessionTimer()
        }
    }
}