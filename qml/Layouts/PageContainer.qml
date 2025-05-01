// Main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Components 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "App with Sidebar and Header"

    // Layout for the entire window
    ColumnLayout {
        anchors.fill: parent

        // Header component with background color set directly in Main.qml
        Rectangle {
            width: parent.width
            height: 60
            color: "#6200EE"  // Set the background color directly

            Header {
                anchors.centerIn: parent
                Text {
                    anchors.centerIn: parent
                    text: "App Header"
                    font.pixelSize: 24
                    color: "white"
                }
            }
        }

        // Main content layout with sidebar
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Sidebar component (imported from Components)
            Sidebar {
                width: 200
                Layout.fillHeight: true
            }

            // Main content area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "lightgray"  // Background color for the content area

                // Main content area
                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "white"

                    Text {
                        text: "Main content goes here"
                        anchors.centerIn: parent
                        font.pointSize: 20
                    }
                }
            }
        }
    }
}
