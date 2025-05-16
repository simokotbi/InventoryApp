import QtQuick 2.15

pragma Singleton

Item {
    // Typography defaults
    property string fontFamily: Typography.fontFamily
    property int headingSize: Typography.headingSize
    property int headlineSize: Typography.headlineSize
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
    property color primaryColor: "#1A1A24"       // Updated primary color
    property color primaryVariant: "#496F5D"     // Updated primary variant
    property color secondaryColor: "#4C9F70"     // Updated secondary color
    property color backgroundColor: "#CAFFB9" 
    property color whiteBackground: "#fff"       // Updated background color
    property color surfaceColor: "#E98A15"       // Updated surface color
    property color errorColor: "#df2935"
    property color onPrimary: "#FFFFFF"
    property color onSecondary: "#000000"
    property color onBackground: "#000000"
    property color onSurface: "#1A1A24"
    property color onError: "#df2935"
    property color test: "#c2e7da"
}