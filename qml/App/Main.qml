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

    ColumnLayout {
        anchors.fill: parent

        Header { Layout.fillWidth: true }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Sidebar {
                onNavigateToPage: (pageName) => {
                    contentLoader.source = pageName
                }
            }

            // This replaces the entire main content area
            Loader {
                id: contentLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: "MainContent.qml"  // Default page
            }
        }
    }

}
