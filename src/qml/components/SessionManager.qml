import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int autoLogoutMinutes: settingsHandler.autoLogout
    property int sessionTimeoutHours: settingsHandler.sessionTimeout
    property bool enabled: authHandler.isLoggedIn

    Timer {
        id: activityTimer
        interval: root.autoLogoutMinutes * 60 * 1000  // Convert minutes to milliseconds
        running: root.enabled && root.autoLogoutMinutes > 0
        onTriggered: {
            if (authHandler.isLoggedIn) {
                authHandler.logout()
            }
        }
    }

    Timer {
        id: sessionTimer
        interval: root.sessionTimeoutHours * 60 * 60 * 1000  // Convert hours to milliseconds
        running: root.enabled
        onTriggered: {
            if (authHandler.isLoggedIn) {
                authHandler.logout()
            }
        }
    }

    function resetActivityTimer() {
        if (activityTimer.running) {
            activityTimer.restart()
        }
    }

    function resetSessionTimer() {
        if (sessionTimer.running) {
            sessionTimer.restart()
        }
    }

    Connections {
        target: settingsHandler
        function onSettingsChanged() {
            activityTimer.interval = root.autoLogoutMinutes * 60 * 1000
            sessionTimer.interval = root.sessionTimeoutHours * 60 * 60 * 1000
            if (root.enabled) {
                activityTimer.restart()
                sessionTimer.restart()
            }
        }
    }
}