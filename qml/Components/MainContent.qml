import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0
import QtQuick.Layouts 1.15
import Layouts 1.0
import QtPositioning
import QtLocation 6.9

Rectangle {
    id: content
    color: Theme.backgroundColor
    radius: 8
    Layout.fillWidth: true
    Layout.fillHeight: true

    Label {
        anchors.centerIn: parent
        text: "Welcome to the Main Content!"
        font.pixelSize: Theme.headlineSize
        color: Theme.onBackground
    }
    Plugin{
        id:mappluginId
        name:"osm"
       
     
    }
   Map {
        id: map
        anchors.fill: parent
        plugin: mappluginId
        center: QtPositioning.coordinate(59.91, 10.75) // Oslo
        zoomLevel: 14
        
        }

}
