// Custom input field component
import QtQuick 2.15
import QtQuick.Controls 2.15
import "../styles"

TextField {
    id: customInput
    
    property string label: ""
    property string errorText: ""
    property bool hasError: errorText.length > 0
    property alias iconSource: leftIcon.source
    property bool showIcon: iconSource !== ""
    
    // Theme colors (updated from Theme singleton)
    property color backgroundColor: typeof Theme !== "undefined" ? Theme.backgroundColor : "#F5F5F5" // Changed from Theme.surface
    property color borderColor: hasError ? 
        (typeof Theme !== "undefined" ? Theme.errorColor : "#F44336") : // Changed from Theme.error
        (typeof Theme !== "undefined" ? Theme.borderColor : "#E0E0E0") // Changed from Theme.border
    property color textColor: typeof Theme !== "undefined" ? Theme.textColor : "#212121" // Changed from Theme.text
    property color placeholderColor: typeof Theme !== "undefined" ? Theme.textColorSecondary : "#757575" // Changed from Theme.textSecondary
    
    height: 48
    selectByMouse: true
    
    leftPadding: showIcon ? 48 : 16
    rightPadding: 16
    topPadding: 12
    bottomPadding: 12
    
    font.family: typeof Theme !== "undefined" ? Theme.fontFamily : "Segoe UI"
    font.pixelSize: typeof Theme !== "undefined" ? Theme.fontSize : 14 // Changed from Theme.fontSizeNormal
    color: textColor
    
    placeholderTextColor: placeholderColor
    
    background: Rectangle {
        color: backgroundColor
        border.color: customInput.activeFocus ? 
            (typeof Theme !== "undefined" ? Theme.primaryColor : "#2196F3") : borderColor // Changed from Theme.primary
        border.width: customInput.activeFocus ? 2 : 1
        radius: typeof Theme !== "undefined" ? Theme.cardRadius : 4 // Changed from Theme.borderRadius
        
        Behavior on border.color {
            ColorAnimation {
                duration: 100 // Fallback, was Theme.animationDurationFast
            }
        }
        
        Behavior on border.width {
            NumberAnimation {
                duration: 100 // Fallback, was Theme.animationDurationFast
            }
        }
    }
    
    // Left icon
    Rectangle {
        id: leftIcon
        visible: showIcon
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20
        color: "transparent"
        
        property string source: ""
        
        Text {
            // Fallback icon if no source provided
            visible: parent.source === ""
            anchors.centerIn: parent
            text: "🔍"
            font.pixelSize: 16
        }
    }
    
    // Label
    Text {
        id: labelText
        visible: label.length > 0
        text: label
        font.family: typeof Theme !== "undefined" ? Theme.fontFamily : "Segoe UI"
        font.pixelSize: typeof Theme !== "undefined" ? Theme.fontSizeSmall : 12
        color: textColor // Ensure consistency, was Theme.textColor
        anchors.bottom: customInput.top
        anchors.bottomMargin: 4
        anchors.left: customInput.left
    }
    
    // Error text
    Text {
        id: errorLabel
        visible: hasError
        text: errorText
        font.family: typeof Theme !== "undefined" ? Theme.fontFamily : "Segoe UI"
        font.pixelSize: typeof Theme !== "undefined" ? Theme.fontSizeSmall : 12
        color: typeof Theme !== "undefined" ? Theme.errorColor : "#F44336" // Changed from Theme.error
        anchors.top: customInput.bottom
        anchors.topMargin: 4
        anchors.left: customInput.left
        anchors.right: customInput.right
        wrapMode: Text.WordWrap
    }
}
