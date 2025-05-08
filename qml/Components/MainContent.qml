import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0
import QtQuick.Layouts 1.15
import Layouts 1.0
import QtPositioning
import QtLocation 6.9

Rectangle {
    id: content
    color: "#e3e8ed"
    radius: 8
    Layout.fillWidth: true
    Layout.fillHeight: true

    Label {
        anchors.centerIn: parent
       // text: //"Welcome to the Main Content!"
        font.pixelSize: Theme.headlineSize
        color: Theme.onBackground
    }
         Column {
            id: buttonColumn
            anchors.fill: parent
            anchors.margins: 1
            spacing: 1
          ItremCard{}
           Card{}
       // ButtonSecondary{
           // text://"testign styles"
            
       // }
       //ToggleButton{text:"testign ToggleButton"}//
         }
}
