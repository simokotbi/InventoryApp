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
        text: "Welcome to the Main Content!"
        font.pixelSize: Theme.headlineSize
        color: Theme.onBackground
    }
        
 Plugin {
        id: mapPlugin
        name: "osm" // "mapboxgl", "esri", ...
        // specify plugin parameters if necessary
          PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: "true"
        }
        PluginParameter {
            name: "osm.mapping.providersrepository.address"
            value: "http://maps-redirect.qt.io/osm/5.6/"
        }
    }

    Map {
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(59.91, 10.75) // Oslo
        zoomLevel: 14
    }


        ButtonSecondary{
            text:"testign styles"
            
        }
        ToggleButton{text:"testign ToggleButton"}

}
