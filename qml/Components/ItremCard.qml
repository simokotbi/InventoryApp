import QtQuick 2.15
import QtQuick

Flipable {
    id: flipable
    width: 240
    height: 240

    property bool flipped: false

    front: Image { source: "../src/database.svg"; anchors.centerIn: parent }
    back: Image { source: "../src/folder.svg"; anchors.centerIn: parent }

    transform: Rotation {
        id: rotation
        origin.x: flipable.width / 2
        origin.y: flipable.height / 2
        axis.x: 0; axis.y: 1; axis.z: 0 // Rotate around y-axis
        angle: 0
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: 180 }
        when: flipable.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: 2000 }
    }

    // Timer for automatic flipping
    Timer {
        interval: 5000 // Flip every 5 seconds
        running: true
        repeat: true
        onTriggered: flipable.flipped = !flipable.flipped
    }
}