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

                    ColumnLayout {
                        anchors.fill: parent

                        DataTable {
                            id: dataTableComponent
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: ListModel {
                                ListElement { identifier: "1"; name: "Alice"; age: "25"; country: "USA" }
                                ListElement { identifier: "2"; name: "Bob"; age: "30"; country: "UK" }
                                ListElement { identifier: "3"; name: "Charlie"; age: "28"; country: "Canada" }
                                ListElement { identifier: "4"; name: "Diana"; age: "35"; country: "Germany" }
                            }
                        }
                    }
                }
            }
        }
    }
}