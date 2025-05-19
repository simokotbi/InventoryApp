import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Rectangle {
    color: "white"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.defaultMargin
        spacing: Theme.defaultSpacing

        Text {
            text: "Analytics Overview"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
        }

        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            spacing: Theme.defaultSpacing * 2

            Repeater {
                model: [
                    { label: "Metric A", value: 70 },
                    { label: "Metric B", value: 45 },
                    { label: "Metric C", value: 85 }
                ]

                Rectangle {
                    width: 100
                    height: parent.height
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * (modelData.value / 100)
                        color: Theme.primaryColor
                        opacity: 0.8
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -25
                        width: parent.width
                        text: modelData.label
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.fontFamily
                        color: Theme.textColor
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -45
                        width: parent.width
                        text: modelData.value + "%"
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.fontFamily
                        color: Theme.primaryColor
                    }
                }
            }
        }
    }
}