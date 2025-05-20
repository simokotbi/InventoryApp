import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import Theme

Button {
    id: root
    property bool secondary: false
    property bool outlined: false
    property bool compact: false
    property bool iconOnly: false

    implicitHeight: compact ? 32 : 40
    implicitWidth: {
        if (iconOnly) return implicitHeight
        if (compact) return Math.max(implicitHeight, contentItem.implicitWidth + (padding * 2))
        return Math.max(120, contentItem.implicitWidth + (padding * 2))
    }
    
    padding: compact ? Theme.defaultPadding * 0.75 : Theme.defaultPadding

    Material.accent: secondary ? Theme.secondaryColor : Theme.primaryColor
    Material.foreground: outlined ? (root.down ? "white" : Material.accent) : "white"
    Material.background: outlined ? "transparent" : Material.accent

    contentItem: Text {
        text: root.text
        font {
            family: Theme.fontFamily
            pixelSize: compact ? Theme.fontSizeSmall : Theme.fontSizeMedium
            bold: !outlined
        }
        color: root.Material.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitHeight: root.implicitHeight
        implicitWidth: root.implicitWidth
        color: outlined ? "transparent" : root.Material.background
        border.color: root.Material.accent
        border.width: outlined ? 2 : 0
        radius: height / 4
        opacity: enabled ? 1 : 0.3
        
        Rectangle {
            anchors.fill: parent
            color: root.pressed ? (outlined ? root.Material.accent : "white") : "transparent"
            opacity: root.pressed ? 0.2 : 0
            radius: parent.radius
        }
        
        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    states: [
        State {
            name: "hovered"
            when: hoverHandler.hovered
            PropertyChanges {
                target: root.background
                color: outlined ? Qt.rgba(root.Material.accent.r, root.Material.accent.g, root.Material.accent.b, 0.1) : Qt.lighter(root.Material.background, 1.1)
            }
        }
    ]
}