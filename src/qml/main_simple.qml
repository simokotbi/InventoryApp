import QtQuick 2.15
import QtQuick.Controls 2.15
import "screens" as Screens

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Business Management System"
    
    property bool isLoading: true
    
    StackView {
        id: mainStack
        anchors.fill: parent
        
        initialItem: Screens.LoadingScreen {
            onLoadingComplete: {
                mainWindow.isLoading = false
                console.log("Loading completed")
            }
        }
    }
    
    Component.onCompleted: {
        console.log("Application started")
    }
}
