import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "../styles"

Popup {
    id: root
    
    property string title: "Information"
    property string message: ""
    property string type: "info" // "info", "success", "warning", "error"
    property bool autoClose: true
    property int autoCloseDelay: 3000
    
    signal accepted()
    signal dismissed()
    
    width: Math.min(400, parent ? parent.width * 0.9 : 400)
    height: contentColumn.height + 40
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0
    
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        id: backgroundRect
        color: Theme.backgroundColor
        border.color: typeColor
        border.width: 2
        radius: Theme.cardRadius
        
        DropShadow {
            anchors.fill: parent
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            color: "#40000000"
            source: parent
        }
    }
    
    readonly property color typeColor: {
        switch(type) {
            case "success": return "#4CAF50"
            case "warning": return "#FF9800"
            case "error": return "#F44336"
            default: return Theme.primaryColor
        }
    }
    
    readonly property string typeIcon: {
        switch(type) {
            case "success": return "qrc:/assets/icons/check-circle.svg"
            case "warning": return "qrc:/assets/icons/warning.svg"
            case "error": return "qrc:/assets/icons/error.svg"
            default: return "qrc:/assets/icons/info.svg"
        }
    }
    
    contentItem: Column {
        id: contentColumn
        spacing: Theme.spacing
        
        Row {
            spacing: Theme.spacing
            width: parent.width
            
            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: root.typeColor
                anchors.verticalCenter: titleText.verticalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: {
                        switch(root.type) {
                            case "success": return "✓"
                            case "warning": return "!"
                            case "error": return "✗"
                            default: return "i"
                        }
                    }
                    color: "white"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }
            }
            
            Text {
                id: titleText
                text: root.title
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.textColor
                width: parent.width - parent.spacing - 24
                wrapMode: Text.WordWrap
            }
        }
        
        Text {
            text: root.message
            font.pixelSize: Theme.fontSize
            color: Theme.textColorSecondary
            width: parent.width
            wrapMode: Text.WordWrap
            visible: root.message !== ""
        }
        
        Row {
            spacing: Theme.spacing
            anchors.right: parent.right
            
            Button {
                text: "OK"
                highlighted: true
                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
        }
    }
    
    Timer {
        id: autoCloseTimer
        interval: root.autoCloseDelay
        running: root.visible && root.autoClose && root.type !== "error"
        onTriggered: {
            root.dismissed()
            root.close()
        }
    }
    
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "scale"; from: 0.8; to: 1; duration: 200; easing.type: Easing.OutBack }
        }
    }
    
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "scale"; from: 1; to: 0.8; duration: 150 }
        }
    }
}
