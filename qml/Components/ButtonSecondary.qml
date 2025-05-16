// components/ButtonSecondary.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15  // for Qt.darker / Qt.lighter
import Themestyles 1.0

Button {
    id: btn
    hoverEnabled: true

    // Single background block with pressed/hover/default
    background: Rectangle {
        radius: Theme.cornerRadius

        // compute colors dynamically
        property color base   : Theme.secondaryColor
        property color hover  : Qt.lighter(base, 1.2)
        property color pressed: Qt.darker(base, 1.2)

        color: btn.pressed
             ? pressed
             : btn.hovered
                 ? hover
                 : base
    }

    // slightly shrink on press for tactile feedback
    transform: Scale {
        origin.x: btn.width/2
        origin.y: btn.height/2
        xScale: btn.pressed ? 0.97 : 1.0
        yScale: btn.pressed ? 0.97 : 1.0
    }

    contentItem: Text {
        text: btn.text
        color: Theme.onPrimary
        font.family: Theme.fontFamily
        font.pointSize: Theme.buttonSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
