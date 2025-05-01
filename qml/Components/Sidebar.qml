// qml/components/Sidebar.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import App 1.0
import Themestyles 1.0
import Layouts 1.0

Rectangle {
    id: sidebar
    Layout.preferredWidth: 200
    Layout.fillHeight: true
    color: Theme.surfaceColor

    // Header at the top
    Rectangle {
        id: headerRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#E6AF2E"

        Text {
            anchors.centerIn: parent
            text: qsTr("Sidebar")
            color: Theme.onPrimary
            font.family: Theme.fontFamily
            font.pointSize: Theme.headlineSize
            font.bold: true
        }
    }

    // Content area
    Rectangle {
        id: contentBackground
        anchors {
            top: headerRect.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: "#e0e2db"  // Light greenish background

        Column {
            id: buttonColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Stylish Buttons
            Button {
                text: qsTr("Item 1")
                background: Rectangle {
                    color: Theme.secondaryColor
                    radius: 8
                }
                contentItem: Text {
                    text: qsTr("Item 1")
                    color: Theme.onPrimary
                    font.family: Theme.fontFamily
                    font.pointSize: 16
                    anchors.centerIn: parent
                }
                onClicked: console.log("Item 1 clicked")
            }

            Button {
                text: qsTr("Item 2")
                background: Rectangle {
                    color: Theme.secondaryColor
                    radius: 8
                }
                contentItem: Text {
                    text: qsTr("Item 2")
                    color: Theme.onPrimary
                    font.family: Theme.fontFamily
                    font.pointSize: 16
                    anchors.centerIn: parent
                }
                onClicked: console.log("Item 2 clicked")
            }

            Button {
                text: qsTr("Item 3")
                background: Rectangle {
                    color: Theme.secondaryColor
                    radius: 8
                }
                contentItem: Text {
                    text: qsTr("Item 3")
                    color: Theme.onPrimary
                    font.family: Theme.fontFamily
                    font.pointSize: 16
                    anchors.centerIn: parent
                }
                onClicked: console.log("Item 3 clicked")
            }
        }
    }
}
