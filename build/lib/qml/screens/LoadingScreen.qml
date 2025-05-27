import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "../styles"
import "../components"

Rectangle {
    id: root
    
    property string message: "Loading..."
    property bool showProgress: true
    property real progress: 0.0
    
    color: Theme.backgroundColor
    
    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing * 2
        
        // App Logo/Icon
        Rectangle {
            width: 120
            height: 120
            radius: 60
            color: Theme.primaryColor
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                anchors.centerIn: parent
                text: "CO"
                font.pixelSize: 48
                font.weight: Font.Bold
                color: "white"
            }
            
            // Pulsing animation
            SequentialAnimation on scale {
                running: true
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.1; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.1; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
            }
        }
        
        // App Name
        Text {
            text: "ChaOffice"
            font.pixelSize: Theme.fontSizeXLarge
            font.weight: Font.Bold
            color: Theme.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: "Business Management System"
            font.pixelSize: Theme.fontSize
            color: Theme.textColorSecondary
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Loading indicator
        Column {
            spacing: Theme.spacing
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Spinner
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "transparent"
                border.color: Theme.primaryColor
                border.width: 3
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.primaryColor
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 2
                }
                
                RotationAnimation on rotation {
                    running: true
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 1000
                }
            }
            
            Text {
                text: root.message
                font.pixelSize: Theme.fontSize
                color: Theme.textColorSecondary
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Progress bar
            Rectangle {
                width: 200
                height: 4
                radius: 2
                color: Theme.borderColor
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.showProgress
                
                Rectangle {
                    width: parent.width * root.progress
                    height: parent.height
                    radius: parent.radius
                    color: Theme.primaryColor
                    
                    Behavior on width {
                        NumberAnimation { duration: 300 }
                    }
                }
            }
        }
    }
    
    // Version info
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Theme.spacing * 2
        text: "v0.1.0"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.textColorSecondary
    }
}
