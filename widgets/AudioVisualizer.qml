import Quickshell
import Quickshell.Io
import QtQuick
import "../theme" as Theme

Item {
    id: root

    // ── Public API ─────────────────────────────────────────────────────
    property bool  playing:  false
    property int   bars:     20
    property color barColor: Theme.Catppuccin.accent

    // ── Geometry ───────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: 48

    // ── Internal ───────────────────────────────────────────────────────
    property var  barValues: []
    property real amplitude: playing ? 1.0 : 0.0
    Behavior on amplitude {
        NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
    }

    // ── Cava process ───────────────────────────────────────────────────
    Process {
        id: cavaProcess
        command: [
            "sh", "-c",
            "cava -p <(echo '[output]\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=100\n[general]\nbars=20')"
        ]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.trim().split(";").filter(s => s !== "")
                if (parts.length === 0) return
                root.barValues = parts.map(v => parseInt(v) / 100.0)
                canvas.requestPaint()
            }
        }
    }


    Canvas {
        id: canvas
        anchors.fill: parent

        property real phase: 0.0

        onPaint: {
            const ctx    = getContext("2d")
            const w      = width
            const h      = height
            const count  = root.bars
            const barW   = 3
            const gap    = (w - count * barW) / (count + 1)
            const midY   = h / 2
            const maxAmp = (h / 2) - 2
            const amp    = maxAmp * root.amplitude

            ctx.clearRect(0, 0, w, h)
            ctx.fillStyle = Qt.rgba(
                root.barColor.r,
                root.barColor.g,
                root.barColor.b,
                0.85
            )

            for (let i = 0; i < count; i++) {
                let barH

                if (root.barValues.length > 0) {
                    // Real data from cava — map bar index to available values
                    const idx = Math.floor(i * root.barValues.length / count)
                    barH = Math.max(2, amp * (root.barValues[idx] ?? 0))
                } else {
                    // Fallback sine until cava starts
                    const t   = phase + i * 0.45
                    const raw = Math.sin(t) * 0.65 + Math.sin(t * 1.9 + 1.1) * 0.35
                    barH = Math.max(2, amp * Math.abs(raw))
                }

                const x = gap + i * (barW + gap)

                const r2 = barW / 2
                const bx = x
                const by = midY - barH
                const bw = barW
                const bh = barH * 2

                ctx.beginPath()
                ctx.moveTo(bx + r2, by)
                ctx.arcTo(bx + bw, by,      bx + bw, by + bh, r2)
                ctx.arcTo(bx + bw, by + bh, bx,      by + bh, r2)
                ctx.arcTo(bx,      by + bh, bx,      by,      r2)
                ctx.arcTo(bx,      by,      bx + bw, by,      r2)
                ctx.closePath()
                ctx.fill()
            }
        }
    }

    // Fallback timer — runs only until cava starts sending data
    Timer {
        interval: 32
        running:  root.barValues.length === 0
        repeat:   true
        onTriggered: {
            canvas.phase += root.playing ? 0.12 : 0.018
            canvas.requestPaint()
        }
    }

    // Idle repaint while paused so amplitude fade still animates
    Timer {
        interval: 32
        running:  !root.playing && root.barValues.length > 0
        repeat:   true
        onTriggered: canvas.requestPaint()
    }

    onAmplitudeChanged: canvas.requestPaint()
}
