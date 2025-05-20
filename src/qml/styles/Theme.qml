pragma Singleton
import QtQuick

QtObject {
    id: theme

    // Dynamic properties that change based on settings
    property bool isDarkMode: settingsHandler ? settingsHandler.darkMode : false
    property string primaryColorHex: settingsHandler ? settingsHandler.primaryColor : "#3498DB"
    property string currentFontFamily: settingsHandler ? settingsHandler.fontFamily : "Segoe UI"

    // Colors - Using proper color type for all color properties
    property color primaryColor: primaryColorHex
    property color secondaryColor: isDarkMode ? "#2ECC71" : "#27AE60"
    property color backgroundColor: isDarkMode ? "#2C3E50" : "#FFFFFF"
    property color textColor: isDarkMode ? "#ECF0F1" : "#2C3E50"
    property color errorColor: "#E74C3C"
    property color successColor: "#27AE60"
    property color warningColor: "#F39C12"
    property color borderColor: isDarkMode ? Qt.lighter(backgroundColor, 1.2) : Qt.darker(backgroundColor, 1.1)

    // Dark mode specific colors
    property color darkModeSecondaryBg: "#34495E"
    property color darkModeHoverColor: Qt.lighter("#2C3E50", 1.2)

    // Spacing and sizing
    property int defaultMargin: 16
    property int defaultPadding: 12
    property int defaultSpacing: 8
    property int cornerRadius: 4

    // Font sizes
    property int fontSizeSmall: 12
    property int fontSizeMedium: 14
    property int fontSizeLarge: 16
    property int fontSizeHeading: 24

    // Font properties
    property string fontFamily: currentFontFamily

    // Computed properties for dynamic theming
    property color rippleColor: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.2)
    property color hoverColor: isDarkMode ? Qt.lighter(backgroundColor, 1.2) : Qt.darker(backgroundColor, 1.02)

    // Button properties
    property color buttonTextColor: isDarkMode ? "#FFFFFF" : "#FFFFFF"
    property int buttonHeight: 40

    // Input properties
    property color inputBorderColor: isDarkMode ? Qt.lighter("#2C3E50", 1.5) : Qt.darker("#FFFFFF", 1.2)
    property color inputBackgroundColor: isDarkMode ? Qt.lighter("#2C3E50", 1.2) : "#FFFFFF"

    // Component transitions
    Behavior on backgroundColor { ColorAnimation { duration: 200 } }
    Behavior on textColor { ColorAnimation { duration: 200 } }
    Behavior on primaryColor { ColorAnimation { duration: 200 } }
    Behavior on secondaryColor { ColorAnimation { duration: 200 } }
    Behavior on borderColor { ColorAnimation { duration: 200 } }
}