import QtQuick 2.15
import QtQuick.Controls 2.15
import "screens" as Screens

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Business Management System - ChaOffice"

    property bool isLoading: true

    StackView {
        id: mainStack
        anchors.fill: parent

        initialItem: Screens.LoadingScreen {
            onLoadingComplete: {
                mainWindow.isLoading = false
                console.log("Loading completed - showing login screen")
                mainStack.replace("screens/LoginScreen.qml")
            }
        }
    }

    Component.onCompleted: {
        console.log("Business Management Application started")
    }
}
