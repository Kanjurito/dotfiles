// ~/.config/quickshell/media-player/Equalizer.qml
import QtQuick

Item {
    id: root
    width: 200
    height: 60

    property bool active: false
    property color barColor: "#89b4fa"

    readonly property int barCount: 24
    readonly property real barW: (width - (barCount - 1) * 2) / barCount

    property var heights: []
    property var targets: []
    property var speeds: []

    Component.onCompleted: {
        let h = [], t = [], s = []
        for (let i = 0; i < barCount; i++) {
            h.push(0.05)
            t.push(Math.random() * 0.85 + 0.1)
            s.push(Math.random() * 0.06 + 0.02)
        }
        heights = h
        targets = t
        speeds = s
    }

    Timer {
        interval: 50
        running: root.active
        repeat: true
        onTriggered: {
            let h = root.heights.slice()
            let t = root.targets.slice()
            let s = root.speeds.slice()
            for (let i = 0; i < root.barCount; i++) {
                h[i] += (t[i] - h[i]) * s[i]
                if (Math.abs(h[i] - t[i]) < 0.02) {
                    t[i] = Math.random() * 0.85 + 0.1
                    s[i] = Math.random() * 0.08 + 0.02
                }
            }
            root.heights = h
            root.targets = t
            root.speeds = s
            canvas.requestPaint()
        }
    }

    Timer {
        interval: 80
        running: !root.active && root.heights.length > 0
        repeat: true
        onTriggered: {
            let h = root.heights.slice()
            let any = false
            for (let i = 0; i < root.barCount; i++) {
                if (h[i] > 0.05) { h[i] *= 0.85; any = true }
                else h[i] = 0.05
            }
            root.heights = h
            if (any) canvas.requestPaint()
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const bw = root.barW
            const gap = 2
            const r = 2
            const col = root.barColor.toString()

            for (let i = 0; i < root.barCount; i++) {
                const barH = Math.max(3, root.heights[i] * height)
                const x = i * (bw + gap)
                const y = height - barH

                const grad = ctx.createLinearGradient(0, y, 0, height)
                grad.addColorStop(0, col)
                grad.addColorStop(1, col.replace(")", ", 0.2)").replace("rgb", "rgba"))
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.moveTo(x + r, y)
                ctx.lineTo(x + bw - r, y)
                ctx.arcTo(x + bw, y, x + bw, y + r, r)
                ctx.lineTo(x + bw, y + barH)
                ctx.lineTo(x, y + barH)
                ctx.lineTo(x, y + r)
                ctx.arcTo(x, y, x + r, y, r)
                ctx.closePath()
                ctx.fill()
            }
        }
    }
}
