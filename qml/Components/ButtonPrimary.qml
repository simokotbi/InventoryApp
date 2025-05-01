import QtQuick 2.15
import QtQuick.Controls 2.15
import Themestyles 1.0
import QtQuick.Layouts 1.15

Button {
    text: "Login"  // Set the button text directly

    // Use the theme for styling
    font.family: Theme.fontFamily
    font.pointSize: Theme.bodySize
    background: Rectangle {
        color: Theme.primaryColor
        radius: 4
    }

    Layout.fillWidth: true
    Layout.preferredWidth: 300
    Layout.maximumWidth: 400


    contentItem: Text {
        text: "Login"  // Bind text to the button's text property
        color: Theme.onPrimary  // Ensure the text color matches the theme
        anchors.centerIn: parent
    }
}
