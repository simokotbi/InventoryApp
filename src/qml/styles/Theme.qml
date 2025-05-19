pragma Singleton
import QtQuick

QtObject {
    readonly property color primaryColor: "#3498DB"
    readonly property color secondaryColor: "#2ECC71"
    readonly property color backgroundColor: "#F5F6FA"
    readonly property color textColor: "#2C3E50"
    readonly property color errorColor: "#E74C3C"
    readonly property color successColor: "#27AE60"
    
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeHeading: 24
    
    readonly property string fontFamily: "Segoe UI"
    
    readonly property real defaultPadding: 16.0
    readonly property real defaultMargin: 16.0
    readonly property real defaultSpacing: 8.0
    readonly property real cornerRadius: 4.0
}