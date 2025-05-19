import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import Theme

TextField {
    id: root
    property bool isPassword: false
    property string label: ""
    property bool showError: false
    property string errorText: ""

    width: parent.width
    height: 40
    color: Theme.textColor
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeMedium
    
    Material.accent: Theme.primaryColor
    Material.foreground: Theme.textColor
    
    echoMode: isPassword ? TextInput.Password : TextInput.Normal
    
    background: Rectangle {
        color: "white"
        border.color: root.showError ? Theme.errorColor : 
                     root.activeFocus ? Theme.primaryColor : "#DEDEDE"
        border.width: root.activeFocus ? 2 : 1
        radius: Theme.cornerRadius
    }

    Text {
        visible: label !== ""
        text: label
        color: Theme.textColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        anchors {
            bottom: parent.top
            bottomMargin: 4
            left: parent.left
        }
    }

    Text {
        visible: showError && errorText !== ""
        text: errorText
        color: Theme.errorColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        anchors {
            top: parent.bottom
            topMargin: 4
            left: parent.left
        }
    }
}