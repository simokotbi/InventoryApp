import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: dashboardPage
    title: "Dashboard"

    Rectangle {
        anchors.fill: parent
        color: "lightblue"

        Text {
            anchors.centerIn: parent
            text: "Welcome to the Dashboard"
            font.pixelSize: 24
        }
    }
}