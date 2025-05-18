// qml/Components/DataTable.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Themestyles 1.0

Item {
    id: tableRoot
    property alias model: tableView.model
    property var columns: []

    width: parent.width
    height: 300

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor

        TableView {
            id: tableView
            anchors.fill: parent
            clip: true
            rowHeightProvider: function(row) { return 40 }

            delegate: Item {
                implicitHeight: 40
                implicitWidth: 100

                Rectangle {
                    anchors.fill: parent
                    color: index % 2 === 0 ? "#f5f5f5" : "#ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: styleData.value
                        font.pixelSize: Theme.bodySize
                        color: Theme.onBackground
                    }
                }
            }

            Component.onCompleted: {
                for (var i = 0; i < columns.length; i++) {
                    var col = columns[i];
                    tableView.addColumn({
                        role: col.role,
                        title: col.title,
                        width: col.width || 150
                    });
                }
            }
        }
    }
}
