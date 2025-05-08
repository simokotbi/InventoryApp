import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects // For DropShadow

Item {
    width: 300
    height: 200

    DropShadow {
        anchors.fill: card
        source: card
        horizontalOffset: 0
        verticalOffset: 4
        radius: 8
        color: "#40000000"
        samples: 16
    }

    Rectangle {
        id: card
        width: parent.width
        height: parent.height
        radius: 12
        color: "white"
        border.color: "#dddddd"

        // Card content
        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "QML Card"
                font.pointSize: 16
                color: "#333"
            }
        }
    }
}
