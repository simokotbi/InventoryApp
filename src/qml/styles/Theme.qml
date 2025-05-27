// Theme singleton for consistent styling
pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme
    
    // Theme state
    property bool isDarkMode: false
    property string currentTheme: isDarkMode ? "dark" : "light"
    
    // Font settings
    property string fontFamily: "Segoe UI"
    property int fontSizeSmall: 12
    property int fontSize: 14
    property int fontSizeLarge: 16
    property int fontSizeXLarge: 20
    property int fontSizeXXLarge: 24
    
    // Spacing and sizing
    property int spacingSmall: 4
    property int spacing: 8
    property int spacingLarge: 16
    property int spacingXLarge: 24
    
    property int buttonHeight: 40
    property int inputHeight: 36
    property int headerHeight: 60
    property int sidebarWidth: 250
    
    property int borderRadius: 6
    property int cardRadius: 8
    property int borderWidth: 1
    
    // Animation settings
    property int animationDuration: 200
    property int animationDurationFast: 100
    property int animationDurationSlow: 300
    
    // Light theme colors
    readonly property var lightColors: ({
        primary: "#2196F3",
        primaryLight: "#64B5F6",
        primaryDark: "#1976D2",
        secondary: "#FF9800",
        backgroundColor: "#FFFFFF",
        cardColor: "#FFFFFF",
        sidebarColor: "#F8F9FA",
        headerColor: "#F5F5F5",
        alternateBackgroundColor: "#FAFAFA",
        textColor: "#212121",
        textColorSecondary: "#757575",
        borderColor: "#E0E0E0",
        hoverColor: "#F5F5F5",
        disabledColor: "#BDBDBD",
        successColor: "#4CAF50",
        warningColor: "#FF9800",
        errorColor: "#F44336"
    })
    
    // Dark theme colors
    readonly property var darkColors: ({
        primary: "#2196F3",
        primaryLight: "#64B5F6",
        primaryDark: "#1976D2",
        secondary: "#FF9800",
        backgroundColor: "#121212",
        cardColor: "#1E1E1E",
        sidebarColor: "#1E1E1E",
        headerColor: "#2C2C2C",
        alternateBackgroundColor: "#1A1A1A",
        textColor: "#FFFFFF",
        textColorSecondary: "#B0B0B0",
        borderColor: "#333333",
        hoverColor: "#2C2C2C",
        disabledColor: "#666666",
        successColor: "#4CAF50",
        warningColor: "#FF9800",
        errorColor: "#F44336"
    })
    
    // Current theme colors
    readonly property var currentColors: isDarkMode ? darkColors : lightColors
    
    // Exposed color properties
    property color primaryColor: currentColors.primary
    property color primaryColorLight: currentColors.primaryLight
    property color primaryColorDark: currentColors.primaryDark
    property color secondaryColor: currentColors.secondary
    property color backgroundColor: currentColors.backgroundColor
    property color cardColor: currentColors.cardColor
    property color sidebarColor: currentColors.sidebarColor
    property color headerColor: currentColors.headerColor
    property color alternateBackgroundColor: currentColors.alternateBackgroundColor
    property color textColor: currentColors.textColor
    property color textColorSecondary: currentColors.textColorSecondary
    property color borderColor: currentColors.borderColor
    property color hoverColor: currentColors.hoverColor
    property color disabledColor: currentColors.disabledColor
    property color successColor: currentColors.successColor
    property color warningColor: currentColors.warningColor
    property color errorColor: currentColors.errorColor
    
    // Convenience aliases
    property alias primary: theme.primaryColor
    property alias background: theme.backgroundColor
    property alias text: theme.textColor
    property alias border: theme.borderColor
    
    // Function to toggle theme
    function toggleTheme() {
        isDarkMode = !isDarkMode
        updateTheme()
    }
    
    function setTheme(dark) {
        isDarkMode = dark
        updateTheme()
    }
      function updateTheme() {
        if (typeof appBridge !== "undefined" && appBridge.configHandler) {
            appBridge.configHandler.setTheme(isDarkMode ? "dark" : "light")
        }
    }
    
    // Initialize theme from config
    Component.onCompleted: {
        if (typeof appBridge !== "undefined" && appBridge.configHandler) {
            isDarkMode = appBridge.configHandler.currentTheme === "dark"
        }
    }
}
