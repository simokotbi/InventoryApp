import QtQuick 2.15
import "../styles"
import "../components"

Rectangle {
    id: root
    
    property string title: ""
    property string value: ""
    property string icon: ""
    property color iconColor: Theme.primaryColor
    property bool enabled: true
    
    height: 120
    color: Theme.cardColor
    border.color: Theme.borderColor
    border.width: 1
    radius: Theme.cardRadius
    opacity: enabled ? 1.0 : 0.6
    
    // Hover effect
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.scale = 1.02
        onExited: parent.scale = 1.0
    }
    
    Behavior on scale {
        NumberAnimation { duration: 150 }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingSmall
        
        SvgIcon {
            source: root.icon
            size: 32
            color: root.iconColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: root.value
            font.pixelSize: Theme.fontSizeXLarge
            font.weight: Font.Bold
            color: Theme.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: root.title
            font.pixelSize: Theme.fontSize
            color: Theme.textColorSecondary
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
