import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Components 1.0
import Themestyles 1.0

Page {
    visible: true
    width: 800
    height: 600
    title: qsTr("Inventory")

    Item {
        id: fadeWrapper
        anchors.fill: parent
        opacity: 0.0

        // Fade-in animation when loaded
        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        Component.onCompleted: {
            fadeWrapper.opacity = 1.0
        }

        ColumnLayout {
            anchors.fill: parent

            Header { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Sidebar { }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.centerIn: parent
                        MainContent { }
                    }
                }
            }
        }
    }
}
