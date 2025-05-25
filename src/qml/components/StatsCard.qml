import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
// import BusinessApp 1.0  // Removed - using context properties

Rectangle {
    id: statsCard
    
    property string title: ""
    property string value: ""
    property string icon: ""
    property color color: themeManager.primaryColor
    property real change: 0
    property bool isWarning: false
    
    color: themeManager.surfaceColor
    border.color: themeManager.dividerColor
    border.width: 1
    radius: 8
    
    // Hover effect
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.color = Qt.lighter(themeManager.surfaceColor, 1.1)
        onExited: parent.color = themeManager.surfaceColor
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        
        // Header with icon
        RowLayout {
            Layout.fillWidth: true
            
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                color: statsCard.color
                radius: 20
                
                Text {
                    anchors.centerIn: parent
                    text: statsCard.icon
                    font.pixelSize: 18
                    color: "white"
                }
            }
            
            Item {
                Layout.fillWidth: true
            }
            
            // Change indicator
            Rectangle {
                visible: !statsCard.isWarning && statsCard.change !== 0
                Layout.preferredWidth: changeText.contentWidth + 8
                Layout.preferredHeight: 20
                color: statsCard.change >= 0 ? "#4CAF50" : themeManager.errorColor
                radius: 10
                
                Text {
                    id: changeText
                    anchors.centerIn: parent
                    text: (statsCard.change >= 0 ? "+" : "") + statsCard.change.toFixed(1) + "%"
                    font.pixelSize: 10
                    color: "white"
                }
            }
        }
        
        // Value
        Text {
            text: statsCard.value
            font.pixelSize: 24
            font.bold: true
            color: themeManager.textColor
            Layout.fillWidth: true
        }
        
        // Title
        Text {
            text: statsCard.title
            font.pixelSize: 14
            color: themeManager.secondaryTextColor
            Layout.fillWidth: true
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}
