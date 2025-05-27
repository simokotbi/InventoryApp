// Custom button component
import QtQuick 2.15
import QtQuick.Controls 2.15
import "../styles"

Button {
    id: customButton
    
    property string variant: "primary" // primary, secondary, outline, text
    property bool isLoading: false
    property string iconSource: ""
    property bool showIcon: iconSource !== ""
    
    // Theme colors
    property color primaryColor: typeof Theme !== "undefined" ? Theme.primary : "#2196F3"
    property color primaryDarkColor: typeof Theme !== "undefined" ? Theme.primaryDark : "#1976D2"
    property color surfaceColor: typeof Theme !== "undefined" ? Theme.surface : "#F5F5F5"
    property color textColor: typeof Theme !== "undefined" ? Theme.text : "#212121"
    property color borderColor: typeof Theme !== "undefined" ? Theme.border : "#E0E0E0"
    
    height: typeof Theme !== "undefined" ? Theme.buttonHeight : 40
    
    font.family: typeof Theme !== "undefined" ? Theme.fontFamily : "Segoe UI"
    font.pixelSize: typeof Theme !== "undefined" ? Theme.fontSizeNormal : 14
    font.weight: Font.Medium
    
    enabled: !isLoading
    
    // Button colors based on variant
    property color buttonColor: {
        switch(variant) {
            case "primary": return primaryColor
            case "secondary": return surfaceColor
            case "outline": return "transparent"
            case "text": return "transparent"
            default: return primaryColor
        }
    }
    
    property color buttonTextColor: {
        switch(variant) {
            case "primary": return "#FFFFFF"
            case "secondary": return textColor
            case "outline": return primaryColor
            case "text": return primaryColor
            default: return "#FFFFFF"
        }
    }
    
    property color hoverColor: {
        switch(variant) {
            case "primary": return primaryDarkColor
            case "secondary": return Qt.darker(surfaceColor, 1.1)
            case "outline": return Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.1)
            case "text": return Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.1)
            default: return primaryDarkColor
        }
    }
    
    background: Rectangle {
        color: customButton.hovered ? hoverColor : buttonColor
        border.color: variant === "outline" ? primaryColor : "transparent"
        border.width: variant === "outline" ? 1 : 0
        radius: typeof Theme !== "undefined" ? Theme.borderRadius : 4
        
        Behavior on color {
            ColorAnimation {
                duration: typeof Theme !== "undefined" ? Theme.animationDurationFast : 100
            }
        }
        
        // Loading indicator
        Rectangle {
            id: loadingIndicator
            visible: isLoading
            anchors.centerIn: parent
            width: 20
            height: 20
            color: "transparent"
            
            Rectangle {
                width: 4
                height: 4
                radius: 2
                color: buttonTextColor
                anchors.centerIn: parent
                
                SequentialAnimation on opacity {
                    running: isLoading
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.3; duration: 600 }
                    NumberAnimation { from: 0.3; to: 1; duration: 600 }
                }
            }
        }
    }
    
    contentItem: Row {
        spacing: 8
        anchors.centerIn: parent
        visible: !isLoading
        
        // Icon
        Text {
            id: buttonIcon
            visible: showIcon
            text: iconSource || "⚫"
            font.pixelSize: 16
            color: buttonTextColor
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Text
        Text {
            text: customButton.text
            font: customButton.font
            color: buttonTextColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // Hover effects
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
    
    // Press effects
    MouseArea {
        anchors.fill: parent
        onPressed: {
            customButton.scale = 0.98
        }
        onReleased: {
            customButton.scale = 1.0
            customButton.clicked()
        }
        onCanceled: {
            customButton.scale = 1.0
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: typeof Theme !== "undefined" ? Theme.animationDurationFast : 100
        }
    }
}
