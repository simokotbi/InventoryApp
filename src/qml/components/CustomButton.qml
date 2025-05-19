import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import Theme

Button {
    id: root
    property bool secondary: false
    property bool outlined: false

    height: 40
    padding: Theme.defaultPadding

    Material.accent: secondary ? Theme.secondaryColor : Theme.primaryColor
    Material.foreground: outlined ? (root.down ? "white" : Material.accent) : "white"
    Material.background: outlined ? "transparent" : Material.accent

    contentItem: Text {
        text: root.text
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeMedium
        }
        color: root.Material.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        color: outlined ? "transparent" : root.Material.background
        border.color: root.Material.accent
        border.width: outlined ? 2 : 0
        radius: Theme.cornerRadius
        opacity: enabled ? 1 : 0.3
        
        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}