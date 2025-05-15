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

    // Define signals
    signal loadDashboardPage()
    signal loadSettingsPage()
    signal loadReportsPage()
    signal navigateToPage(string pageName)

    Rectangle { // Right border
        width: 1
        height: parent.height
        color: "#a5b0c0"
        anchors.right: parent.right
    }

    // Header at the top
    Rectangle {
        id: headerRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#fff"

        border.color: "#617079"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: qsTr("Sidebar")
            color: Theme.onSecondary
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
        color: "#fff" // Light greenish background

        Column {
            id: buttonColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Dashboard Button
            SidebarButton {
                iconSource: "../src/airplay.svg"
                text: "Dashboard"
                onClicked: navigateToPage("DashboardPage.qml")
                
            }
            // ReportsPage Button
            SidebarButton {
                iconSource: "../src/folder.svg"
                text: "Reports"
                onClicked: navigateToPage("ReportsPage.qml")
         
            }
         
        }
    }
}