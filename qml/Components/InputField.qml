import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0
import QtQuick.Layouts 1.15


TextField {
    
    placeholderTextColor: "#999"
    padding: 10
    font.family: Theme.fontFamily
    font.pointSize: Theme.bodySize
    
        background: Rectangle {
             color: Theme.whiteBackground
             radius: 4
        }
   
    Layout.fillWidth: true
    Layout.preferredWidth: 400
    Layout.maximumWidth: 500
}

