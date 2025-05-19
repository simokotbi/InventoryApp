import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components"
import "../views"

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "Application"
    color: Theme.backgroundColor

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
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSizeLarge
                    bold: true
                }
                Layout.alignment: Qt.AlignLeft
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "Logout"
                secondary: true
                onClicked: {
                    authHandler.logout();
                    window.close();
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: Qt.darker(Theme.backgroundColor, 1.05)

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: ["Dashboard", "Analytics", "User Form"]
                    delegate: ItemDelegate {
                        Layout.fillWidth: true
                        height: 48
                        highlighted: contentStack.currentIndex === index

                        contentItem: Text {
                            text: modelData
                            color: parent.highlighted ? Theme.primaryColor : Theme.textColor
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.defaultPadding
                        }

                        background: Rectangle {
                            color: parent.highlighted ? Qt.lighter(Theme.backgroundColor, 1.02) : "transparent"
                        }

                        onClicked: contentStack.currentIndex = index
                    }
                }

                Item { Layout.fillHeight: true }

                ItemDelegate {
                    Layout.fillWidth: true
                    height: 48

                    contentItem: Text {
                        text: "Settings"
                        color: Theme.textColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.defaultPadding
                    }

                    onClicked: {
                        var component = Qt.createComponent("GeneralSettingsPage.qml");
                        if (component.status === Component.Ready) {
                            var settingsWindow = component.createObject(window);
                            settingsWindow.show();
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

            DashboardView {}
            AnalyticsView {}
            UserFormView {}
        }
    }
}