import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0
import QtQuick.Layouts 1.15
import Layouts 1.0
import QtPositioning
import QtLocation 6.9

Rectangle {
    id: content
    color: "#e3e8ed"
    radius: 8
    Layout.fillWidth: true
    Layout.fillHeight: true

    Label {
        anchors.centerIn: parent
        font.pixelSize: Theme.headlineSize
        color: Theme.onBackground
    }

    Column {
        id: buttonColumn
        anchors.centerIn: parent  // Center column both horizontally and vertically
        spacing: Theme.mediumSpacing

        ItremCard {}
        Card {}

        // Uncomment if needed:
        // ButtonSecondary {
        //     text: "Testing styles"
        // }
        // ToggleButton {
        //     text: "Testing ToggleButton"
        // }
    }
}
