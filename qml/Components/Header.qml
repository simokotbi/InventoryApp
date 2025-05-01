import QtQuick        2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15  
import Themestyles 1.0
import Layouts 1.0   

Rectangle {
    // now Layout.fillWidth is valid
    Layout.fillWidth: true
    height: 60
    color: "#2E3A59"
    border.color: "#1F2738"; border.width: 1

    Text {
        anchors.centerIn: parent
        text: qsTr("My Inventory App")
        color: "white"; font.bold: true; font.pointSize: 20
    }
}
