import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Dialog {
    id: messagePopup
    
    property string message: ""
    property string type: "info" // "info", "success", "warning", "error"
    
    signal accepted()
    signal rejected()
    
    modal: true
    anchors.centerIn: parent
    width: Math.min(400, parent.width * 0.9)
    height: Math.min(200, implicitHeight)
    
    Material.accent: themeManager.primaryColor
    
    // Icon and color based on type
    property string iconText: {
        switch(type) {
            case "success": return "✅"
            case "warning": return "⚠️"
            case "error": return "❌"
            default: return "ℹ️"
        }
    }
    
    property color typeColor: {
        switch(type) {
            case "success": return "#4CAF50"
            case "warning": return "#FF9800"
            case "error": return themeManager.errorColor
            default: return themeManager.primaryColor
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Icon and message
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            Text {
                text: messagePopup.iconText
                font.pixelSize: 32
            }
            
            Text {
                text: messagePopup.message
                color: themeManager.textColor
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
        
        // Buttons
        RowLayout {
            Layout.fillWidth: true
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                text: type === "warning" ? "Cancel" : "OK"
                flat: type === "warning"
                Material.foreground: type === "warning" ? themeManager.secondaryTextColor : "white"
                Material.background: type === "warning" ? "transparent" : messagePopup.typeColor
                onClicked: {
                    if (type === "warning") {
                        messagePopup.rejected()
                    } else {
                        messagePopup.accepted()
                    }
                    messagePopup.close()
                }
                visible: type !== "warning" || true
            }
            
            Button {
                text: type === "warning" ? "Delete" : "OK"
                Material.background: messagePopup.typeColor
                Material.foreground: "white"
                visible: type === "warning"
                onClicked: {
                    messagePopup.accepted()
                    messagePopup.close()
                }
            }
        }
    }
    
    // Auto-close for success messages
    Timer {
        interval: 3000
        running: messagePopup.visible && (type === "success" || type === "info")
        onTriggered: {
            messagePopup.accepted()
            messagePopup.close()
        }
    }
}
