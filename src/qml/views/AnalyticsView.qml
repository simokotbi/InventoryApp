import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import Theme
import "../components" as Components

Rectangle {
    color: Theme.backgroundColor

    // Properties to store analytics data
    property var userActivityData: analyticsService.get_user_activity(timeRangeCombo.currentText)
    property var formSubmissionsData: analyticsService.get_form_submissions(timeRangeCombo.currentText)
    property var errorRateData: analyticsService.get_error_rate(timeRangeCombo.currentText)
    property var performanceMetrics: analyticsService.get_performance_metrics()

    ScrollView {
        anchors.fill: parent
        contentHeight: mainColumn.height

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: Theme.defaultSpacing * 2

            // Header Section
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: Theme.defaultMargin

                Text {
                    text: "Analytics"
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSizeHeading
                        bold: true
                    }
                    color: Theme.textColor
                }

                Item { Layout.fillWidth: true }

                ComboBox {
                    id: timeRangeCombo
                    model: ["Last 7 Days", "Last 30 Days", "Last 3 Months", "Last Year"]
                    onCurrentTextChanged: updateCharts()
                }

                Components.CustomButton {
                    text: "Refresh"
                    onClicked: {
                        analyticsService.clear_cache()
                        updateCharts()
                    }
                }

                Components.CustomButton {
                    text: "Export Data"
                    onClicked: notification.show("Data export started", false)
                }
            }

            // User Activity Chart
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                Layout.margins: Theme.defaultMargin
                color: Theme.backgroundColor
                radius: Theme.cornerRadius
                border.color: Theme.borderColor
                border.width: 1

                Components.Chart {
                    id: userActivityChart
                    anchors.fill: parent
                    anchors.margins: Theme.defaultPadding
                    title: "User Activity"
                    type: "line"
                    maxValue: userActivityData.maxValue || 100
                    data: userActivityData.values || []
                    labels: userActivityData.labels || []
                    chartColor: Theme.primaryColor
                }
            }

            // Performance Metrics Chart
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: Theme.backgroundColor
                radius: Theme.cornerRadius
                border.color: Theme.borderColor
                border.width: 1

                Components.Chart {
                    id: performanceChart
                    anchors.fill: parent
                    anchors.margins: Theme.defaultPadding
                    title: "System Performance"
                    type: "line"
                    data: analyticsService ? analyticsService.performanceData : []
                    labels: analyticsService ? analyticsService.performanceLabels : []
                    maxValue: 100
                    chartColor: Theme.primaryColor
                }
            }

            // Request Statistics
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: Theme.backgroundColor
                radius: Theme.cornerRadius
                border.color: Theme.borderColor
                border.width: 1

                Components.Chart {
                    id: requestStatsChart
                    anchors.fill: parent
                    anchors.margins: Theme.defaultPadding
                    title: "API Request Statistics"
                    type: "bar"
                    data: analyticsService ? analyticsService.requestStatsData : []
                    labels: analyticsService ? analyticsService.requestStatsLabels : []
                    maxValue: 100
                    chartColor: Theme.secondaryColor
                    labelRotation: -45
                }
            }

            // Date Range Filter
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 10

                Label {
                    text: "Time Range:"
                    font.family: Theme.fontFamily
                    color: Theme.textColor
                }

                Components.CustomButton {
                    text: "Day"
                    onClicked: analyticsService.setTimeRange("day")
                    highlighted: analyticsService && analyticsService.currentRange === "day"
                }

                Components.CustomButton {
                    text: "Week"
                    onClicked: analyticsService.setTimeRange("week")
                    highlighted: analyticsService && analyticsService.currentRange === "week"
                }

                Components.CustomButton {
                    text: "Month"
                    onClicked: analyticsService.setTimeRange("month")
                    highlighted: analyticsService && analyticsService.currentRange === "month"
                }

                Item {
                    Layout.fillWidth: true
                }

                Components.CustomButton {
                    text: "Refresh Data"
                    onClicked: analyticsService.refreshData()
                }
            }

            // Performance Metrics
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: Theme.defaultMargin
                Layout.preferredHeight: 100
                color: Theme.isDarkMode ? Theme.darkModeSecondaryBg : "white"
                radius: Theme.cornerRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.defaultPadding
                    spacing: Theme.defaultSpacing * 4

                    Repeater {
                        model: [
                            { label: "Avg. Response Time", value: performanceMetrics.avgResponseTime || "0ms" },
                            { label: "Success Rate", value: performanceMetrics.successRate || "0%" },
                            { label: "Active Users", value: performanceMetrics.activeUsers || "0" },
                            { label: "CPU Usage", value: performanceMetrics.cpuUsage || "0%" }
                        ]

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.defaultSpacing

                            Text {
                                text: modelData.label
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.textColor
                                opacity: 0.7
                            }

                            Text {
                                text: modelData.value
                                font {
                                    family: Theme.fontFamily
                                    pixelSize: Theme.fontSizeLarge
                                    bold: true
                                }
                                color: Theme.textColor
                            }
                        }
                    }
                }
            }
        }
    }

    Components.NotificationPopup {
        id: notification
    }

    Timer {
        interval: 60000  // Update every minute
        running: true
        repeat: true
        onTriggered: updateCharts()
    }

    Connections {
        target: analyticsService
        function onDataUpdated() {
            updateCharts()
        }
    }

    function updateCharts() {
        userActivityData = analyticsService.get_user_activity(timeRangeCombo.currentText)
        formSubmissionsData = analyticsService.get_form_submissions(timeRangeCombo.currentText)
        errorRateData = analyticsService.get_error_rate(timeRangeCombo.currentText)
        performanceMetrics = analyticsService.get_performance_metrics()
        notification.show("Charts updated", false)
    }
}