import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components"

Window {
    id: window
    width: 500
    height: 400
    title: "Settings"
    color: Theme.backgroundColor
    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.defaultMargin
        spacing: Theme.defaultSpacing * 2

        Text {
            text: "Application Settings"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
        }

        Text {
            text: "This is a placeholder for application settings. In a real application, you would configure various application settings here."
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Theme.defaultSpacing

            CustomButton {
                text: "Close"
                outlined: true
                onClicked: window.close()
            }

            CustomButton {
                text: "Save Changes"
                enabled: false  // Disabled since this is a placeholder
                onClicked: window.close()
            }
        }
    }
}