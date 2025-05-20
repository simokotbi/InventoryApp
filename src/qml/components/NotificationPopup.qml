import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Theme

Popup {
    id: root
    
    property string message: ""
    property bool isError: false
    property int displayTime: 3000  // Display duration in milliseconds
    
    // Set minimum width and use Layout to handle text wrapping
    width: Math.max(contentLayout.implicitWidth + (padding * 2), 300)
    height: contentLayout.implicitHeight + (padding * 2)
    padding: Theme.defaultPadding * 1.5
    
    anchors.centerIn: Overlay.overlay
    y: 50  // Position it near the top of the screen
    
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        id: backgroundRect
        color: isError ? Theme.errorColor : Theme.successColor
        radius: Theme.cornerRadius
        opacity: 0.95

        // Add shadow using MultiEffect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 2
            shadowBlur: 0.6
            shadowOpacity: 0.3
        }
    }
    
    contentItem: RowLayout {
        id: contentLayout
        spacing: Theme.defaultSpacing
        
        // Add an icon
        Text {
            text: isError ? "⚠" : "✓"
            color: "white"
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }
        
        Text {
            id: contentText
            text: root.message
            color: "white"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
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
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            property: "y"
            from: 0
            to: 50
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 200
            easing.type: Easing.InCubic
        }
    }
    
    function show(msg, error, duration) {
        message = msg
        isError = error
        if (duration !== undefined) {
            displayTime = duration
        }
        open()
    }
}