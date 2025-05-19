import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Theme

Popup {
    id: root
    
    property string message: ""
    property bool isError: false
    property int displayTime: 3000  // Display duration in milliseconds
    
    width: contentText.width + (padding * 2)
    height: contentText.height + (padding * 2)
    padding: Theme.defaultPadding
    
    anchors.centerIn: Overlay.overlay
    
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        color: isError ? Theme.errorColor : Theme.successColor
        radius: Theme.cornerRadius
        opacity: 0.9
    }
    
    contentItem: Text {
        id: contentText
        text: root.message
        color: "white"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }
    
    Timer {
        id: closeTimer
        interval: root.displayTime
        running: root.visible
        onTriggered: root.close()
    }
    
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 200
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 200
        }
    }
    
    function show(msg: string, error: bool = false, duration: int = 3000) {
        message = msg
        isError = error
        displayTime = duration
        open()
    }
}