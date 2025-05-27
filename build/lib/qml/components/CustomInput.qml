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
    property color backgroundColor: typeof Theme !== "undefined" ? Theme.surface : "#F5F5F5"
    property color borderColor: hasError ? 
        (typeof Theme !== "undefined" ? Theme.error : "#F44336") : 
        (typeof Theme !== "undefined" ? Theme.border : "#E0E0E0")
    property color textColor: typeof Theme !== "undefined" ? Theme.text : "#212121"
    property color placeholderColor: typeof Theme !== "undefined" ? Theme.textSecondary : "#757575"
    
    height: 48
    selectByMouse: true
    
    leftPadding: showIcon ? 48 : 16
    rightPadding: 16
    topPadding: 12
    bottomPadding: 12
    
    font.family: typeof Theme !== "undefined" ? Theme.fontFamily : "Segoe UI"
    font.pixelSize: typeof Theme !== "undefined" ? Theme.fontSizeNormal : 14
    color: textColor
    
    placeholderTextColor: placeholderColor
    
    background: Rectangle {
        color: backgroundColor
        border.color: customInput.activeFocus ? 
            (typeof Theme !== "undefined" ? Theme.primary : "#2196F3") : borderColor
        border.width: customInput.activeFocus ? 2 : 1
        radius: typeof Theme !== "undefined" ? Theme.borderRadius : 4
        
        Behavior on border.color {
            ColorAnimation {
                duration: typeof Theme !== "undefined" ? Theme.animationDurationFast : 100
            }
        }
        
        Behavior on border.width {
            NumberAnimation {
                duration: typeof Theme !== "undefined" ? Theme.animationDurationFast : 100
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
        color: textColor
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
        color: typeof Theme !== "undefined" ? Theme.error : "#F44336"
        anchors.top: customInput.bottom
        anchors.topMargin: 4
        anchors.left: customInput.left
        anchors.right: customInput.right
        wrapMode: Text.WordWrap
    }
}
