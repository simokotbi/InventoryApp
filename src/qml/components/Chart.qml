import QtQuick
import QtQuick.Controls
import Theme

Canvas {
    id: root

    property string title: ""
    property string type: "bar"  // "bar" or "line"
    property var data: []
    property var labels: []
    property real maxValue: 100
    property color chartColor: Theme.primaryColor || "#3498DB"  // Fallback color
    property color borderColor: Theme.borderColor || "#DEDEDE"  // Fallback color
    property real labelRotation: 0

    property real padding: 40
    property real bottomPadding: labelRotation !== 0 ? 80 : 60

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()

        // Use Theme colors with fallbacks
        var axisColor = Theme.textColor ? Theme.textColor + "40" : "#2C3E5040"
        var textColor = Theme.textColor || "#2C3E50"

        // Draw title
        ctx.font = "bold 14px \"" + Theme.fontFamily + "\""
        ctx.fillStyle = textColor
        ctx.textAlign = "center"
        ctx.fillText(title, width / 2, 25)

        // Calculate chart area
        var chartWidth = width - 2 * padding
        var chartHeight = height - padding - bottomPadding
        var barWidth = chartWidth / Math.max((data || []).length, 1) * 0.8
        var spacing = chartWidth / Math.max((data || []).length, 1) * 0.2

        // Draw Y-axis
        ctx.beginPath()
        ctx.strokeStyle = axisColor
        ctx.moveTo(padding, padding)
        ctx.lineTo(padding, height - bottomPadding)
        ctx.stroke()

        // Draw Y-axis labels
        ctx.textAlign = "right"
        ctx.font = "12px \"" + Theme.fontFamily + "\""
        for (var i = 0; i <= 5; i++) {
            var yValue = maxValue * (1 - i / 5)
            var y = padding + (chartHeight * i / 5)
            ctx.fillText(Math.round(yValue), padding - 5, y + 4)
            
            // Draw horizontal grid lines
            ctx.beginPath()
            ctx.strokeStyle = borderColor
            ctx.moveTo(padding, y)
            ctx.lineTo(width - padding, y)
            ctx.stroke()
        }

        // Draw X-axis
        ctx.beginPath()
        ctx.strokeStyle = axisColor
        ctx.moveTo(padding, height - bottomPadding)
        ctx.lineTo(width - padding, height - bottomPadding)
        ctx.stroke()

        // Safety check for data array
        if (!data || !data.length) return;

        // Draw data
        if (type === "bar") {
            for (var i = 0; i < data.length; i++) {
                var x = padding + (i * (barWidth + spacing))
                var barHeight = (data[i] / maxValue) * chartHeight
                var y = height - bottomPadding - barHeight

                ctx.fillStyle = chartColor
                ctx.fillRect(x, y, barWidth, barHeight)

                // Draw X-axis labels
                if (labels && labels[i]) {
                    ctx.save()
                    ctx.translate(x + barWidth/2, height - bottomPadding + 10)
                    ctx.rotate(labelRotation * Math.PI / 180)
                    ctx.textAlign = "right"
                    ctx.fillStyle = textColor
                    ctx.fillText(labels[i], 0, 0)
                    ctx.restore()
                }
            }
        } else if (type === "line") {
            ctx.beginPath()
            ctx.strokeStyle = chartColor
            ctx.lineWidth = 2

            for (var i = 0; i < data.length; i++) {
                var x = padding + (i * chartWidth / (data.length - 1))
                var y = height - bottomPadding - (data[i] / maxValue * chartHeight)

                if (i === 0) {
                    ctx.moveTo(x, y)
                } else {
                    ctx.lineTo(x, y)
                }

                // Draw points
                ctx.fillStyle = chartColor
                ctx.beginPath()
                ctx.arc(x, y, 4, 0, 2 * Math.PI)
                ctx.fill()

                // Draw X-axis labels
                if (labels && labels[i]) {
                    ctx.save()
                    ctx.translate(x, height - bottomPadding + 10)
                    ctx.rotate(labelRotation * Math.PI / 180)
                    ctx.textAlign = "right"
                    ctx.fillStyle = textColor
                    ctx.fillText(labels[i], 0, 0)
                    ctx.restore()
                }
            }
            ctx.stroke()
        }
    }

    // Update chart when properties change
    onDataChanged: requestPaint()
    onLabelsChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onChartColorChanged: requestPaint()
    onTypeChanged: requestPaint()
    onMaxValueChanged: requestPaint()
    onLabelRotationChanged: requestPaint()
}