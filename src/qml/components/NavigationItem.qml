import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Button {
    id: navItem
    
    property string icon: ""
    property bool isActive: false
    
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    
    flat: true
    
    Material.background: isActive ? themeManager.accentColor : "transparent"
    Material.foreground: "white"
    
    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12
        
        Text {
            text: navItem.icon
            font.pixelSize: 18
            color: "white"
        }
        
        Text {
            text: navItem.text
            color: "white"
            font.pixelSize: 14
            font.bold: navItem.isActive
            Layout.fillWidth: true
        }
        
        Rectangle {
            visible: navItem.isActive
            width: 4
            height: 20
            color: "white"
            radius: 2
        }
    }
    
    background: Rectangle {
        color: navItem.isActive ? themeManager.accentColor : (navItem.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent")
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
