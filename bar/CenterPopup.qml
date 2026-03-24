import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io 
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../theme" as Theme

// Activated by Bar.qml's center island click.
// In shell.qml:
//   CenterPopup { id: centerPopup }
//   Bar         { onCenterClicked: centerPopup.toggle() }
Scope {
    id: root
    property bool open: false

    function toggle() { open = !open }

    // Also toggle-able via IPC: qs ipc call centerpopup toggle
    IpcHandler {
        target: "centerpopup"
        function toggle() { root.open = !root.open }
    }

    PanelWindow {
        visible: open
        anchors { top: true; left: true; right: true; bottom: true }
        color: "transparent"

        WlrLayershell.namespace: "quickshell:centerpopup"
        WlrLayershell.layer:    WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Keys.onEscapePressed: root.open = false

        // Click outside to dismiss
        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        // ── Popup card ────────────────────────────────────────────────────
        Rectangle {
            id: popup

            width:  680
            height: popupRow.implicitHeight + 28
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:              parent.top
            anchors.topMargin:        Theme.Catppuccin.barHeight - 32

            radius:       Theme.Catppuccin.radius
            color:        Theme.Catppuccin.bgFloat
            border.color: Theme.Catppuccin.border
            border.width: 1

            // Grow from top-center, matching the bar island
            transformOrigin: Item.Top
            scale:   open ? 1.0 : 0.94
            opacity: open ? 1.0 : 0.0
            Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            // Behavior on opacity { NumberAnimation { duration: 180 } }

            // Swallow clicks so backdrop doesn't close us
            MouseArea { anchors.fill: parent }

            RowLayout {
                id: popupRow
                anchors { fill: parent; margins: 14 }
                spacing: 14

                // ── Calendar ─────────────────────────────────────────────
                Item {
                    id: calView
                    Layout.preferredWidth: 290
                    Layout.alignment:      Qt.AlignTop
                    implicitHeight:        calCol.implicitHeight

                    // ── State ──────────────────────────────────────────
                    property var today:     new Date()
                    property int viewYear:  today.getFullYear()
                    property int viewMonth: today.getMonth()   // 0-based

                    readonly property var monthNames: [
                        "January","February","March","April",
                        "May","June","July","August",
                        "September","October","November","December"
                    ]
                    readonly property var dayNames: ["Su","Mo","Tu","We","Th","Fr","Sa"]

                    function buildGrid(year, month) {
                        const firstDow    = new Date(year, month, 1).getDay()
                        const daysInMonth = new Date(year, month + 1, 0).getDate()
                        const daysInPrev  = new Date(year, month,     0).getDate()
                        const cells = []
                        for (let i = 0; i < 42; i++) {
                            if (i < firstDow)
                                cells.push({ day: daysInPrev - firstDow + 1 + i, inMonth: false })
                            else if (i - firstDow < daysInMonth)
                                cells.push({ day: i - firstDow + 1, inMonth: true })
                            else
                                cells.push({ day: i - firstDow - daysInMonth + 1, inMonth: false })
                        }
                        return cells
                    }

                    property var gridCells: buildGrid(viewYear, viewMonth)
                    onViewYearChanged:  gridCells = buildGrid(viewYear, viewMonth)
                    onViewMonthChanged: gridCells = buildGrid(viewYear, viewMonth)

                    Column {
                        id: calCol
                        anchors { left: parent.left; right: parent.right; top: parent.top }
                        spacing: 6

                        // ── Month header ──────────────────────────────
                        Item {
                            width:  parent.width
                            height: 26

                            // Prev month
                            Text {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                text:           "‹"
                                color:          Theme.Catppuccin.fgMuted
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 20
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: {
                                        if (calView.viewMonth === 0) {
                                            calView.viewMonth = 11
                                            calView.viewYear--
                                        } else {
                                            calView.viewMonth--
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text:           calView.monthNames[calView.viewMonth] + "  " + calView.viewYear
                                color:          Theme.Catppuccin.fg
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: Theme.Catppuccin.fontMd
                                font.bold:      true
                            }

                            // Next month
                            Text {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                text:           "›"
                                color:          Theme.Catppuccin.fgMuted
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 20
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: {
                                        if (calView.viewMonth === 11) {
                                            calView.viewMonth = 0
                                            calView.viewYear++
                                        } else {
                                            calView.viewMonth++
                                        }
                                    }
                                }
                            }
                        }

                        // ── Day-of-week headers ───────────────────────
                        Row {
                            width: parent.width
                            Repeater {
                                model: calView.dayNames
                                Text {
                                    width:              calCol.width / 7
                                    horizontalAlignment: Text.AlignHCenter
                                    text:           modelData
                                    color:          Theme.Catppuccin.fgDim
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: Theme.Catppuccin.fontSm
                                }
                            }
                        }

                        // ── Day grid ──────────────────────────────────
                        Grid {
                            columns: 7
                            width:   parent.width
                            spacing: 2

                            Repeater {
                                model: 42
                                delegate: Rectangle {
                                    id: dayCell

                                    property var  cell:    calView.gridCells[index] ?? { day: 0, inMonth: false }
                                    property bool isToday: cell.inMonth
                                        && cell.day      === calView.today.getDate()
                                        && calView.viewMonth === calView.today.getMonth()
                                        && calView.viewYear  === calView.today.getFullYear()

                                    width:  Math.floor(calCol.width / 7) - 2
                                    height: width
                                    radius: width / 2
                                    color:  isToday ? Theme.Catppuccin.accent : "transparent"

                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text:           dayCell.cell.day || ""
                                        color:          dayCell.isToday      ? Theme.Catppuccin.bg
                                                    :   dayCell.cell.inMonth ? Theme.Catppuccin.fg
                                                    :                          Theme.Catppuccin.fgDim
                                        font.family:    Theme.Catppuccin.font
                                        font.pixelSize: Theme.Catppuccin.fontSm
                                        font.bold:      dayCell.isToday
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Divider ───────────────────────────────────────────────
                Rectangle {
                    width:          1
                    Layout.fillHeight: true
                    color:          Theme.Catppuccin.border
                }

                // ── Big media player ──────────────────────────────────────
                Item {
                    id: bigPlayer
                    Layout.fillWidth: true
                    Layout.alignment:      Qt.AlignTop
                    implicitHeight:        playerCol.implicitHeight

                    // ── Player state ───────────────────────────────────
                    property var player: null
                    property real posProgress: 0
                    property real lastPos: 0
                    property real lastPollMs: 0

                    Timer {
                        id: posTimer
                        interval: 500
                        running:  root.open && bigPlayer.player !== null
                        repeat:   true
                        onTriggered: {
                            const p = bigPlayer.player
                            if (!p || p.length <= 0) { bigPlayer.posProgress = 0; return }
                            bigPlayer.lastPos    = p.position
                            bigPlayer.lastPollMs = Date.now()
                            bigPlayer.posProgress = Math.min(p.position / p.length, 1.0)
                        }
                    }

                    // High-frequency display updater
                    Timer {
                        interval: 100
                        running:  root.open && bigPlayer.player !== null
                        repeat:   true
                        onTriggered: {
                            const p = bigPlayer.player
                            if (!p || p.length <= 0 || !(p.isPlaying ?? false)) return
                            const elapsed = (Date.now() - bigPlayer.lastPollMs) / 1000
                            const estimated = bigPlayer.lastPos + elapsed
                            bigPlayer.posProgress = Math.min(estimated / p.length, 1.0)
                        }
                    }
                    Repeater {
                        model: Mpris.players
                        delegate: Item {
                            Component.onCompleted:   { if (index === 0) bigPlayer.player = modelData }
                            Component.onDestruction: { if (index === 0) bigPlayer.player = null }
                        }
                    }

                    // Kick position update whenever a new track starts
                    Connections {
                        target: bigPlayer.player
                        ignoreUnknownSignals: true
                        function onTrackTitleChanged() { posTimer.triggered() }
                        function onIsPlayingChanged()  { posTimer.triggered() }
                    }

                    // ms → "m:ss"
                    function fmt(s) {
                        if (!s || s <= 0) return "0:00"
                        const secs  = Math.floor(s)
                        const h     = Math.floor(secs / 3600)
                        const m     = Math.floor((secs % 3600) / 60)
                        const sec   = secs % 60
                        if (h > 0)
                            return h + ":" + m.toString().padStart(2, "0") + ":" + sec.toString().padStart(2, "0")
                        return m + ":" + sec.toString().padStart(2, "0")
                    }

                    Column {
                        id: playerCol
                        anchors { left: parent.left; right: parent.right; top: parent.top }
                        spacing: 12

                        // ── Album art ──────────────────────────────────
                        Item {
                            id: artBox
                            width:  parent.width
                            height: width

                            Image {
                                id: artImg
                                anchors.fill: parent
                                source:   bigPlayer.player?.trackArtUrl ?? ""
                                fillMode: Image.PreserveAspectCrop
                                smooth:   true
                                visible:  false
                            }

                            MultiEffect {
                                source:           artImg
                                anchors.fill:     artImg
                                maskEnabled:      true
                                maskThresholdMin: 0.5
                                maskSpreadAtMin:  1.0
                                maskSource: ShaderEffectSource {
                                    sourceItem: Rectangle {
                                        width:  artImg.width
                                        height: artImg.height

                                        radius: (bigPlayer.player?.isPlaying ?? false)
                                                ? Theme.Catppuccin.radius
                                                : Theme.Catppuccin.radius + artImg.width / 4

                                        Behavior on radius {
                                            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }
                            }

                            // Fallback music note
                            Text {
                                anchors.centerIn: parent
                                visible:        artImg.status !== Image.Ready
                                text:           "󰎆"
                                color:          Theme.Catppuccin.fgDim
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 52
                            }
                        }

                        // ── Track info ─────────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 3

                            // Clipping wrapper so the scroll doesn't bleed out
                            Item {
                                width:          parent.width
                                implicitHeight: trackTitleText.implicitHeight
                                clip:           true

                                Text {
                                    id:             trackTitleText
                                    text:           bigPlayer.player?.trackTitle ?? "Nothing playing"
                                    color:          Theme.Catppuccin.fg
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: Theme.Catppuccin.fontMd
                                    font.bold:      true
                                    anchors.verticalCenter: parent.verticalCenter

                                    property bool shouldScroll: implicitWidth > parent.width
                                    x: 0
                                    NumberAnimation on x {
                                        running:  trackTitleText.shouldScroll
                                        loops:    Animation.Infinite
                                        from:     0
                                        to:       -(trackTitleText.implicitWidth - trackTitleText.parent.width)
                                        duration: trackTitleText.shouldScroll ? (trackTitleText.implicitWidth - trackTitleText.parent.width) * 30 : 1
                                    }
                                }
                            }

                            Text {
                                width:          parent.width
                                text:           bigPlayer.player?.trackArtist ?? ""
                                visible:        text !== ""
                                color:          Theme.Catppuccin.fgMuted
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: Theme.Catppuccin.fontSm
                                elide:          Text.ElideRight
                            }
                        }

                        // ── Progress bar ───────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 4

                            // Scrubber track
                            Item {
                                id:     scrubber
                                width:  parent.width
                                height: 14

                                Rectangle {
                                    id:     trackBg
                                    width:  parent.width
                                    height: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: 2
                                    color:  Theme.Catppuccin.surface1

                                    // Filled portion
                                    Rectangle {
                                        width:  trackBg.width * bigPlayer.posProgress
                                        height: parent.height
                                        radius: parent.radius
                                        color:  Theme.Catppuccin.accent
                                        Behavior on width {
                                            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                                        }
                                    }

                                    // Thumb dot
                                    Rectangle {
                                        x:      trackBg.width * bigPlayer.posProgress - width / 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        width:  10; height: 10; radius: 5
                                        color:  Theme.Catppuccin.fg
                                        Behavior on x {
                                            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }

                                // Click to seek
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        const p = bigPlayer.player
                                        if (!p || p.length <= 0) return
                                        const ratio = Math.max(0, Math.min(mouse.x / width, 1))
                                        p.position = ratio * p.length
                                        bigPlayer.posProgress = ratio
                                    }
                                }
                            }

                            // Timestamps
                            Item {
                                width:  parent.width
                                height: tsLeft.implicitHeight

                                Text {
                                    id:    tsLeft
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                    text:           bigPlayer.fmt(bigPlayer.lastPos + (Date.now() - bigPlayer.lastPollMs) / 1000)
                                    color:          Theme.Catppuccin.fgDim
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: Theme.Catppuccin.fontSm
                                }

                                Text {
                                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                    text:           bigPlayer.fmt(bigPlayer.player?.length ?? 0)
                                    color:          Theme.Catppuccin.fgDim
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: Theme.Catppuccin.fontSm
                                }
                            }
                        }

                        // ── Transport controls ─────────────────────────
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 18

                            // Previous
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           "󰒮"
                                color:          Theme.Catppuccin.fgMuted
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 18
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    bigPlayer.player?.previous()
                                }
                            }

                            // Play / Pause circle
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width:  42
                                height: 42
                                color:  Theme.Catppuccin.accent
                                radius: (bigPlayer.player?.isPlaying ?? false) ? 8 : 21
                                Behavior on radius {
                                    NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text:           (bigPlayer.player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                                    color:          Theme.Catppuccin.bg
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: 18
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    bigPlayer.player?.togglePlaying()
                                }

                                scale: 1.0
                                Behavior on scale { NumberAnimation { duration: 80 } }
                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  parent.parent.scale = 0.92
                                    onReleased: parent.parent.scale = 1.0
                                    onClicked:  bigPlayer.player?.togglePlaying()
                                }
                            }

                            // Next
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           "󰒭"
                                color:          Theme.Catppuccin.fgMuted
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 18
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    bigPlayer.player?.next()
                                }
                            }
                        }

                        // ── Player name badge ──────────────────────────
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible:        bigPlayer.player !== null
                            text:           bigPlayer.player?.identity ?? ""
                            color:          Theme.Catppuccin.fgDim
                            font.family:    Theme.Catppuccin.font
                            font.pixelSize: Theme.Catppuccin.fontSm
                        }
                    }
                }
            }
        }
    }
}
