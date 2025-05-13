import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: dataTable

    // Default width and height
    width: 600
    height: 400

    // Model property for external assignment
    property alias model: tableModel.model

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Table Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "darkgray"
                Text {
                    anchors.centerIn: parent
                    text: "ID"
                    font.bold: true
                    color: "white"
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "darkgray"
                Text {
                    anchors.centerIn: parent
                    text: "Name"
                    font.bold: true
                    color: "white"
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "darkgray"
                Text {
                    anchors.centerIn: parent
                    text: "Age"
                    font.bold: true
                    color: "white"
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "darkgray"
                Text {
                    anchors.centerIn: parent
                    text: "Country"
                    font.bold: true
                    color: "white"
                }
            }
        }

        // Table Content
        Repeater {
            id: tableModel
            model: model

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: index % 2 === 0 ? "lightgray" : "white"
                    border.color: "gray"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.identifier
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: index % 2 === 0 ? "lightgray" : "white"
                    border.color: "gray"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.name
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: index % 2 === 0 ? "lightgray" : "white"
                    border.color: "gray"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.age
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: index % 2 === 0 ? "lightgray" : "white"
                    border.color: "gray"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.country
                    }
                }
            }
        }
    }
}