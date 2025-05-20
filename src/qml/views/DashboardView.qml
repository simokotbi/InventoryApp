import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import Theme
import "../components" as Components

Rectangle {
    color: Theme.backgroundColor

    ScrollView {
        anchors.fill: parent
        contentHeight: mainColumn.height

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: Theme.defaultSpacing * 2

            // Header Section
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: Theme.defaultMargin

                Text {
                    text: "Dashboard"
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSizeHeading
                        bold: true
                    }
                    color: Theme.textColor
                }

                Item { Layout.fillWidth: true }

                Components.CustomButton {
                    text: "Refresh Data"
                    onClicked: {
                        // TODO: Implement data refresh
                        notification.show("Data refreshed", false)
                    }
                }
            }

            // Quick Stats Grid
            GridLayout {
                Layout.fillWidth: true
                Layout.margins: Theme.defaultMargin
                columns: 3
                columnSpacing: Theme.defaultSpacing * 2
                rowSpacing: Theme.defaultSpacing * 2

                Repeater {
                    model: [
                        { title: "Total Users", value: "1,234", trend: "+5.2%" },
                        { title: "Active Sessions", value: "156", trend: "+2.1%" },
                        { title: "Form Submissions", value: "89", trend: "-1.4%" }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 120
                        radius: Theme.cornerRadius
                        color: Theme.isDarkMode ? Theme.darkModeSecondaryBg : "white"
                        border.color: Theme.isDarkMode ? Qt.lighter(Theme.darkModeSecondaryBg, 1.1) : Qt.darker("white", 1.1)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.defaultPadding

                            Text {
                                text: modelData.title
                                font {
                                    family: Theme.fontFamily
                                    pixelSize: Theme.fontSizeMedium
                                }
                                color: Theme.textColor
                                opacity: 0.7
                            }

                            Text {
                                text: modelData.value
                                font {
                                    family: Theme.fontFamily
                                    pixelSize: Theme.fontSizeHeading
                                    bold: true
                                }
                                color: Theme.textColor
                            }

                            Text {
                                text: modelData.trend
                                font {
                                    family: Theme.fontFamily
                                    pixelSize: Theme.fontSizeMedium
                                }
                                color: modelData.trend.startsWith("+") ? Theme.successColor : Theme.errorColor
                            }
                        }
                    }
                }
            }

            // Recent Activity Section
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: Theme.defaultMargin
                Layout.preferredHeight: 300
                radius: Theme.cornerRadius
                color: Theme.isDarkMode ? Theme.darkModeSecondaryBg : "white"
                border.color: Theme.isDarkMode ? Qt.lighter(Theme.darkModeSecondaryBg, 1.1) : Qt.darker("white", 1.1)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.defaultPadding
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "Recent Activity"
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.fontSizeLarge
                            bold: true
                        }
                        color: Theme.textColor
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: ListModel {
                            ListElement {
                                action: "User Login"
                                user: "john.doe@example.com"
                                timestamp: "5 minutes ago"
                            }
                            ListElement {
                                action: "Form Submitted"
                                user: "jane.smith@example.com"
                                timestamp: "15 minutes ago"
                            }
                            ListElement {
                                action: "Settings Updated"
                                user: "admin@example.com"
                                timestamp: "1 hour ago"
                            }
                        }

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            height: 60

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.defaultPadding
                                spacing: Theme.defaultSpacing

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: Theme.primaryColor
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: action
                                        font {
                                            family: Theme.fontFamily
                                            pixelSize: Theme.fontSizeMedium
                                            bold: true
                                        }
                                        color: Theme.textColor
                                    }

                                    Text {
                                        text: user
                                        font {
                                            family: Theme.fontFamily
                                            pixelSize: Theme.fontSizeSmall
                                        }
                                        color: Theme.textColor
                                        opacity: 0.7
                                    }
                                }

                                Text {
                                    text: timestamp
                                    font {
                                        family: Theme.fontFamily
                                        pixelSize: Theme.fontSizeSmall
                                    }
                                    color: Theme.textColor
                                    opacity: 0.5
                                }
                            }
                        }
                    }
                }
            }

            // System Status Section
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: Theme.defaultMargin
                Layout.preferredHeight: 200
                radius: Theme.cornerRadius
                color: Theme.isDarkMode ? Theme.darkModeSecondaryBg : "white"
                border.color: Theme.isDarkMode ? Qt.lighter(Theme.darkModeSecondaryBg, 1.1) : Qt.darker("white", 1.1)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.defaultPadding
                    spacing: Theme.defaultSpacing

                    Text {
                        text: "System Status"
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.fontSizeLarge
                            bold: true
                        }
                        color: Theme.textColor
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: Theme.defaultSpacing
                        columnSpacing: Theme.defaultSpacing * 2

                        Text {
                            text: "Database Status:"
                            font.family: Theme.fontFamily
                            color: Theme.textColor
                        }

                        Text {
                            text: "Connected"
                            font.family: Theme.fontFamily
                            color: Theme.successColor
                        }

                        Text {
                            text: "Last Backup:"
                            font.family: Theme.fontFamily
                            color: Theme.textColor
                        }

                        Text {
                            text: "2 hours ago"
                            font.family: Theme.fontFamily
                            color: Theme.textColor
                        }

                        Text {
                            text: "Active Users:"
                            font.family: Theme.fontFamily
                            color: Theme.textColor
                        }

                        Text {
                            text: "156"
                            font.family: Theme.fontFamily
                            color: Theme.textColor
                        }

                        Text {
                            text: "Server Load:"
                            font.family: Theme.fontFamily
                            color: Theme.textColor
                        }

                        Text {
                            text: "45%"
                            font.family: Theme.fontFamily
                            color: Theme.warningColor
                        }
                    }
                }
            }
        }
    }

    Components.NotificationPopup {
        id: notification
    }
}