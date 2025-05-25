import QtQuick 2.15

Item {
    signal loadingComplete()
    
    Component.onCompleted: {
        loadingComplete()
    }
}
