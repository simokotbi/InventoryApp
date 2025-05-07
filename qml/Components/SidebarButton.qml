import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Themestyles 1.0

Rectangle {
    id: root
    height: Theme.buttonHeight + Theme.smallSpacing
    width: parent ? parent.width : 200
    color: hovered ? "#eeeeee" : "transparent"
    radius: Theme.cornerRadius

    property alias text: label.text
    property alias iconSource: icon.source

    signal clicked()

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.smallSpacing
        spacing: Theme.smallSpacing

        Image {
            id: icon
            source: ""
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 20
            sourceSize.height: 20
        }

        Label {
            id: label
            text: ""
            font.pixelSize: Theme.buttonSize
            font.family: Theme.fontFamily
            color: Theme.onSurface
            Layout.alignment: Qt.AlignVCenter
        }
    }

    property bool hovered: area.containsMouse
}
