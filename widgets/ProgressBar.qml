import QtQuick
import "../theme" as Theme

Item {
    id: root

    // ── Public API ─────────────────────────────────────────────────────
    property real progress:  0.0   // 0.0 – 1.0
    property real displayProgress: 0
    property color color: Theme.Catppuccin.accent
    property color color2: Theme.Catppuccin.surface0
    property real refreshRate: 32
    Behavior on displayProgress {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    
    onProgressChanged: displayProgress = progress
    
    // ── Geometry ───────────────────────────────────────────────────────
    implicitWidth:  200
    implicitHeight: 48


    Canvas {
        id: canvas
        anchors.fill: parent

        property real phase: 0.0

        onPaint: {
    const ctx    = getContext("2d")
    const w      = width
    const h      = height
    const midY   = h / 2
    const prog   = root.displayProgress
    const fillX  = w * prog
    const beamX = fillX
    const gap   = 6

    ctx.clearRect(0, 0, w, h)
    ctx.lineWidth  = 4
    ctx.lineCap    = "round"
    ctx.lineJoin   = "round"

    // ── Filled portion ──────────────────────────────
    ctx.beginPath()
    ctx.strokeStyle = Qt.rgba(
        color.r,
        color.g,
        color.b,
        1.0
    )
    for (let x = 0; x <= beamX - gap; x++) {
        const y = midY
        x === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
    }
    ctx.stroke()

    // ── Unfilled portion — flat ────────────────────────────
    ctx.beginPath()
    ctx.strokeStyle = Qt.rgba(
        color2.r,
        color2.g,
        color2.b,
        1.0
    )
    ctx.moveTo(beamX , midY)
    ctx.lineTo(w,           midY)
    ctx.stroke()
        }
    }

    Timer {
        interval: refreshRate
        running:  true
        repeat:   true
        onTriggered: {
            canvas.requestPaint()
        }
    }
}
