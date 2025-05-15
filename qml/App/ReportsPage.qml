import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Components 1.0
import Themestyles 1.0


Page {
    id: reportsPage
    title: "Reports"

    Rectangle {
        anchors.fill: parent
        color: "lightcoral"

        Text {
            anchors.centerIn: parent
            text: "Welcome to Reports"
            font.pixelSize: 24
        }
    }
     ColumnLayout {
                        anchors.fill: parent

                      DataTable {
    columns: [
        { role: "name", title: "Name" },
        { role: "age", title: "Age" },
        { role: "country", title: "Country" }
    ]
    model: ListModel {
        ListElement { name: "Alice"; age: "25"; country: "USA" }
        ListElement { name: "Bob"; age: "30"; country: "UK" }
        ListElement { name: "Charlie"; age: "28"; country: "Canada" }
    }
}

                    }
}