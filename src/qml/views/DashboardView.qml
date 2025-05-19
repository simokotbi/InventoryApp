import QtQuick
import QtQuick.Controls
import "../styles"

Rectangle {
    color: "white"
    
    TableView {
        anchors.fill: parent
        anchors.margins: Theme.defaultMargin
        clip: true

        model: ListModel {
            ListElement { id: "1"; name: "Item One"; status: "Active"; lastUpdated: "2025-05-19" }
            ListElement { id: "2"; name: "Item Two"; status: "Pending"; lastUpdated: "2025-05-18" }
            ListElement { id: "3"; name: "Item Three"; status: "Completed"; lastUpdated: "2025-05-17" }
            ListElement { id: "4"; name: "Item Four"; status: "Active"; lastUpdated: "2025-05-16" }
            ListElement { id: "5"; name: "Item Five"; status: "Inactive"; lastUpdated: "2025-05-15" }
        }

        delegate: Rectangle {
            implicitWidth: 150
            implicitHeight: 40
            border.width: 1
            border.color: Qt.lighter(Theme.textColor, 1.9)

            Text {
                anchors.fill: parent
                anchors.margins: Theme.defaultSpacing
                text: display
                color: Theme.textColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}