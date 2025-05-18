import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0
import QtQuick.Layouts 1.15
import Layouts 1.0
import Components 1.0

Page {
    id: dashboardPage
    title: "Dashboard"

    Rectangle {
        anchors.fill: parent
       color: Theme.whiteBackground

        Text {
            anchors.centerIn: parent
            text: "Welcome to the Dashboard"
            font.pixelSize: 24
            color:Theme.primaryColor
        
        }
    }
     ColumnLayout {
                        anchors.fill: parent
                        ButtonSecondary{
                            text: "Welcome"
                            
                        }
     }
    
}