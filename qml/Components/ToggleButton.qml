import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0

Button {
    id: btn
    property bool toggled: false
    checkable: true
    checked: toggled

    background: Rectangle {
        radius: Theme.cornerRadius
        color: btn.checked 
            ? Theme.primaryColor 
            : Theme.surfaceColor
    }
    contentItem: Text {
        text: btn.text
        color: btn.checked 
            ? Theme.onPrimary 
            : Theme.onSurface
        font.family: Theme.fontFamily
        font.pointSize: Theme.buttonSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    onCheckedChanged: toggled = checked
    hoverEnabled: true
}
