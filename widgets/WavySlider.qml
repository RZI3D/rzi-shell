import QtQuick
import "../theme" as Theme

Item {
    id: root

    // ── Public API ─────────────────────────────────────────────────────
    property real progress:  0.0   // 0.0 – 1.0
    property bool playing:   false
    property real displayProgress: 0
    Behavior on displayProgress {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    // keep displayProgress chasing progress
    onProgressChanged: {
        if (!isDragging) {
            displayProgress = progress
        }
    }
    onAmplitudeChanged: canvas.requestPaint()
    property bool isDragging: mouseHandler.pressed
    Timer {
        id: throttleTimer
        interval: 500
        repeat: true
        running: root.isDragging
        onTriggered: {
            root.seeked(mouseHandler.calculateRatio())
        }
    }
    signal seeked(real ratio)      // emitted on click, ratio 0.0 – 1.0

    // ── Geometry ───────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: 48

    // ── Internal ───────────────────────────────────────────────────────
    property real amplitude: playing ? 1.0 : 0.0
    Behavior on amplitude {
        NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property real phase: 0.0

        onPaint: {
    const ctx    = getContext("2d")
    const w      = width
    const h      = height
    const midY   = h / 2
    const maxAmp = h / 12
    const prog   = root.displayProgress
    const amp    = maxAmp * root.amplitude
    const fillX  = w * prog
    const beamX = fillX
    const gap   = 6

    ctx.clearRect(0, 0, w, h)
    ctx.lineWidth  = 4
    ctx.lineCap    = "round"
    ctx.lineJoin   = "round"

    // ── Filled portion — wavy ──────────────────────────────
    ctx.beginPath()
    ctx.strokeStyle = Qt.rgba(
        Theme.Catppuccin.accent.r,
        Theme.Catppuccin.accent.g,
        Theme.Catppuccin.accent.b,
        1.0
    )
    for (let x = 0; x <= beamX - gap; x++) {
        const y = midY + Math.sin((x / w) * Math.PI * 10 + phase) * amp
        x === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
    }
    ctx.stroke()

    // ── Unfilled portion — flat ────────────────────────────
    ctx.beginPath()
    ctx.strokeStyle = Qt.rgba(
        Theme.Catppuccin.surface2.r,
        Theme.Catppuccin.surface2.g,
        Theme.Catppuccin.surface2.b,
        1.0
    )
    ctx.moveTo(beamX + gap, midY)
    ctx.lineTo(w,           midY)
    ctx.stroke()

    // ── Vertical beam at progress point ───────────────────
    ctx.beginPath()
    ctx.lineWidth   = 4
    ctx.strokeStyle = Qt.rgba(
        Theme.Catppuccin.fg.r,
        Theme.Catppuccin.fg.g,
        Theme.Catppuccin.fg.b,
        1.0
    )
    ctx.moveTo(fillX, midY - (h / 4))
    ctx.lineTo(fillX, midY + (h / 4))
    ctx.stroke()
        }
    }

    // Phase animation — faster while playing, slow idle when paused
    Timer {
        interval: 32
        running:  true
        repeat:   true
        onTriggered: {
            canvas.phase += root.playing ? 0.10 : 0.015
            canvas.requestPaint()
        }
    }

    // Click to seek
    MouseArea {
        id: mouseHandler
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        // Helper to get the 0.0 - 1.0 value
        function calculateRatio() {
            return Math.max(0, Math.min(mouseX / width, 1))
        }

        onPressed: (mouse) => {
            // Immediate update for visual snappiness
            root.displayProgress = calculateRatio()
            // Optional: Immediate seek on first click
            root.seeked(calculateRatio()) 
        }

        onPositionChanged: (mouse) => {
            if (pressed) {
                // Update ONLY the visual bar immediately so it feels smooth
                root.displayProgress = calculateRatio()
            }
        }
        
        onReleased: (mouse) => {
            // Final seek to ensure we land exactly where the user let go
            root.seeked(calculateRatio())
        }
    }
}
