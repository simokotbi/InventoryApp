pragma Singleton
import QtQuick 2.15

QtObject {
    // Colors
    property color primaryColor: "#6200EE"
    property color primaryVariant: "#3700B3"
    property color secondaryColor: "#0b5d1e"
    property color backgroundColor: "#FFFFFF"
    property color surfaceColor: "#FFFFFF"
    property color errorColor: "#df2935"
    property color onPrimary: "#FFFFFF"
    property color onSecondary: "#000000"
    property color onBackground: "#000000"
    property color onSurface: "#000000"
    property color onError: "#df2935"
    property color test:"#c2e7da"

    // Typography
    property string fontFamily: "Arial"    // or Roboto, etc.
    property int headlineSize: 24
    property int titleSize: 20
    property int bodySize: 16
    property int captionSize: 12

    // Spacing (optional, for margins/padding)
    property int smallSpacing: 4
    property int mediumSpacing: 8
    property int largeSpacing: 16
}
