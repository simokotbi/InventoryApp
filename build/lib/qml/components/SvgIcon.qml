import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "../styles"

Item {
    id: root
    
    property string source: ""
    property color color: Theme.primaryColor
    property int size: 24
    property real rotation: 0
    property bool enabled: true
    
    signal clicked()
    
    width: size
    height: size
    
    Image {
        id: iconImage
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectFit
        smooth: true
        rotation: root.rotation
        visible: !root.source.toString().endsWith('.svg')
        
        opacity: root.enabled ? 1.0 : 0.5
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
        
        Behavior on rotation {
            NumberAnimation { duration: 200 }
        }
    }
    
    // Color overlay for SVG icons
    ColorOverlay {
        anchors.fill: iconImage
        source: iconImage
        color: root.enabled ? root.color : Theme.disabledColor
        visible: root.source.toString().endsWith('.svg')
        rotation: root.rotation
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
        
        hoverEnabled: true
        onEntered: root.scale = 1.1
        onExited: root.scale = 1.0
    }
    
    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
}
