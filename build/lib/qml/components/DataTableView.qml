import QtQuick 2.15
import QtQuick.Controls 2.15
import "../styles"

Rectangle {
    id: root
    
    property var model: null
    property var columns: []
    property bool sortingEnabled: true
    property bool selectionEnabled: true
    property int currentRow: -1
    property string emptyText: "No data available"
    
    signal rowClicked(int row, var rowData)
    signal rowDoubleClicked(int row, var rowData)
    
    color: Theme.backgroundColor
    border.color: Theme.borderColor
    border.width: 1
    radius: Theme.cardRadius
    
    Column {
        anchors.fill: parent
        anchors.margins: 1
        
        // Header
        Rectangle {
            width: parent.width
            height: 48
            color: Theme.headerColor
            
            Row {
                anchors.fill: parent
                
                Repeater {
                    model: root.columns
                    
                    Rectangle {
                        width: modelData.width || (parent.width / root.columns.length)
                        height: parent.height
                        color: "transparent"
                        border.color: Theme.borderColor
                        border.width: index < root.columns.length - 1 ? 1 : 0
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingSmall
                            
                            Text {
                                text: modelData.title || ""
                                font.pixelSize: Theme.fontSize
                                font.weight: Font.Bold
                                color: Theme.textColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            SvgIcon {
                                source: sortColumn === modelData.field ? 
                                    (sortOrder === Qt.AscendingOrder ? 
                                        "qrc:/assets/icons/arrow-up.svg" : 
                                        "qrc:/assets/icons/arrow-down.svg") : 
                                    "qrc:/assets/icons/sort.svg"
                                size: 16
                                color: Theme.textColorSecondary
                                visible: root.sortingEnabled && modelData.sortable !== false
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.sortingEnabled && modelData.sortable !== false
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (sortColumn === modelData.field) {
                                    sortOrder = sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder
                                } else {
                                    sortColumn = modelData.field
                                    sortOrder = Qt.AscendingOrder
                                }
                                sortModel()
                            }
                        }
                    }
                }
            }
        }
        
        // Content
        Rectangle {
            width: parent.width
            height: parent.height - 48
            color: "transparent"
            clip: true
            
            ScrollView {
                anchors.fill: parent
                
                ListView {
                    id: listView
                    model: root.model
                    delegate: rowDelegate
                    
                    // Empty state
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: 200
                        color: "transparent"
                        visible: listView.count === 0
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacing
                            
                            SvgIcon {
                                source: "qrc:/assets/icons/database.svg"
                                size: 64
                                color: Theme.textColorSecondary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: root.emptyText
                                font.pixelSize: Theme.fontSize
                                color: Theme.textColorSecondary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }
    
    property string sortColumn: ""
    property int sortOrder: Qt.AscendingOrder
    
    function sortModel() {
        // Custom sorting logic would go here
        // For now, this is a placeholder
        console.log("Sorting by", sortColumn, sortOrder === Qt.AscendingOrder ? "ASC" : "DESC")
    }
    
    Component {
        id: rowDelegate
        
        Rectangle {
            width: listView.width
            height: 48
            color: root.selectionEnabled && root.currentRow === index ? 
                Theme.primaryColorLight : 
                (index % 2 === 0 ? Theme.backgroundColor : Theme.alternateBackgroundColor)
            
            border.color: root.selectionEnabled && root.currentRow === index ? 
                Theme.primaryColor : "transparent"
            border.width: 1
            
            Row {
                anchors.fill: parent
                
                Repeater {
                    model: root.columns
                    
                    Rectangle {
                        width: modelData.width || (parent.width / root.columns.length)
                        height: parent.height
                        color: "transparent"
                        
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                if (modelData.field && typeof rowData !== 'undefined') {
                                    var value = rowData[modelData.field]
                                    if (modelData.format && typeof modelData.format === 'function') {
                                        return modelData.format(value)
                                    }
                                    return value !== undefined ? value.toString() : ""
                                }
                                return ""
                            }
                            font.pixelSize: Theme.fontSize
                            color: Theme.textColor
                            elide: Text.ElideRight
                            width: parent.width - Theme.spacing * 2
                        }
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.selectionEnabled) {
                        root.currentRow = index
                    }
                    root.rowClicked(index, rowData)
                }
                onDoubleClicked: {
                    root.rowDoubleClicked(index, rowData)
                }
            }
            
            // Hover effect
            Rectangle {
                anchors.fill: parent
                color: Theme.primaryColor
                opacity: parent.MouseArea.containsMouse ? 0.1 : 0
                
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
        }
    }
}
