import QtQuick 2.15

pragma Singleton

Item {
    // Typography defaults
    property string fontFamily: Typography.fontFamily
    property int headingSize: Typography.headingSize
    property int headlineSize:Typography.headlineSize
    property int bodySize: Typography.bodySize
    property int captionSize: Typography.captionSize

    // Button sizing
    property int buttonSize: 16            // font size for button labels
    property int buttonHeight: 36          // height of buttons

    // Shape & spacing
    property int cornerRadius: 4
    property int smallSpacing: 8
    property int mediumSpacing: 16
    property int largeSpacing: 24

    // Color palette
     property color primaryColor: "#6200EE"
    property color primaryVariant: "#3700B3"
    property color secondaryColor: "#2E3A59"
    property color backgroundColor: "#FFFFFF"
    property color surfaceColor: "#FFFFFF"
    property color errorColor: "#df2935"
    property color onPrimary: "#FFFFFF"
    property color onSecondary: "#000000"
    property color onBackground: "#000000"
    property color onSurface: "#1a1a24"
    property color onError: "#df2935"
    property color test:"#c2e7da"
}
 