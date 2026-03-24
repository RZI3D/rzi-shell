import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.Layouts
import "../theme" as Theme
import "../widgets" as Widgets

Scope {
    id: root
    property bool open: false

    function toggle() { open = !open }

    IpcHandler {
        target: "centerpopup"
        function toggle() { root.open = !root.open }
    }

    PanelWindow {
        visible: open
        anchors { top: true; left: true; right: true; bottom: true }
        color: "transparent"

        WlrLayershell.namespace:     "quickshell:centerpopup"
        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Keys.onEscapePressed: root.open = false

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

            // Cascade Material theming to all controls inside
            Material.theme:      Material.Dark
            Material.accent:     Theme.Catppuccin.accent
            Material.foreground: Theme.Catppuccin.fg
            Material.background: Theme.Catppuccin.bgFloat

            transformOrigin: Item.Top
            scale:   open ? 1.0 : 0.94
            opacity: open ? 1.0 : 0.0
            Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

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

                    property var today:     new Date()
                    property int viewYear:  today.getFullYear()
                    property int viewMonth: today.getMonth()

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
                            height: 32

                            ToolButton {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                text:           "‹"
                                font.pixelSize: 20
                                implicitWidth:  32; implicitHeight: 32
                                onClicked: {
                                    if (calView.viewMonth === 0) { calView.viewMonth = 11; calView.viewYear-- }
                                    else calView.viewMonth--
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

                            ToolButton {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                text:           "›"
                                font.pixelSize: 20
                                implicitWidth:  32; implicitHeight: 32
                                onClicked: {
                                    if (calView.viewMonth === 11) { calView.viewMonth = 0; calView.viewYear++ }
                                    else calView.viewMonth++
                                }
                            }
                        }

                        // ── Day-of-week headers ───────────────────────
                        Row {
                            width: parent.width
                            Repeater {
                                model: calView.dayNames
                                Text {
                                    width:               calCol.width / 7
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
                                        && cell.day          === calView.today.getDate()
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
                                                      : dayCell.cell.inMonth ? Theme.Catppuccin.fg
                                                      :                        Theme.Catppuccin.fgDim
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
                    width:             1
                    Layout.fillHeight: true
                    color:             Theme.Catppuccin.border
                }

                // ── Big media player ──────────────────────────────────────
                Item {
                    id: bigPlayer
                    Layout.fillWidth:  true
                    Layout.alignment:  Qt.AlignTop
                    implicitHeight:    playerCol.implicitHeight

                    property var  player:      null
                    property real posProgress: 0
                    property real lastPos:     0
                    property real lastPollMs:  0

                    Repeater {
                        model: Mpris.players
                        delegate: Item {
                            Component.onCompleted:   { if (index === 0) bigPlayer.player = modelData }
                            Component.onDestruction: { if (index === 0) bigPlayer.player = null }
                        }
                    }

                    // Source-of-truth poll every 500ms
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

                    // Interpolation at 100ms for smooth display
                    Timer {
                        interval: 100
                        running:  root.open && bigPlayer.player !== null
                        repeat:   true
                        onTriggered: {
                            const p = bigPlayer.player
                            if (!p || p.length <= 0 || !(p.isPlaying ?? false)) return
                            const elapsed   = (Date.now() - bigPlayer.lastPollMs) / 1000
                            const estimated = bigPlayer.lastPos + elapsed
                            bigPlayer.posProgress = Math.min(estimated / p.length, 1.0)
                        }
                    }

                    Connections {
                        target: bigPlayer.player
                        ignoreUnknownSignals: true
                        function onTrackTitleChanged() { posTimer.triggered() }
                        function onIsPlayingChanged()  { posTimer.triggered() }
                    }

                    function fmt(s) {
                        if (!s || s <= 0) return "0:00"
                        const secs = Math.floor(s)
                        const h    = Math.floor(secs / 3600)
                        const m    = Math.floor((secs % 3600) / 60)
                        const sec  = secs % 60
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
                                id:       artImg
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
                                                : artImg.width / 2
                                        Behavior on radius {
                                            NumberAnimation { duration: 400; easing.type: Easing.InOutCubic }
                                        }
                                    }
                                }
                            }

                            // Fallback
                            Rectangle {
                                anchors.fill: parent
                                visible:      artImg.status !== Image.Ready
                                radius:       (bigPlayer.player?.isPlaying ?? false)
                                              ? Theme.Catppuccin.radius
                                              : width / 2
                                color:        Theme.Catppuccin.surface0
                                Behavior on radius {
                                    NumberAnimation { duration: 400; easing.type: Easing.InOutCubic }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text:           "󰎆"
                                    color:          Theme.Catppuccin.fgDim
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: 52
                                }
                            }
                        }

                        // ── Track info ─────────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 3

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
                                    SequentialAnimation on x {
                                        running: trackTitleText.shouldScroll
                                        loops:   Animation.Infinite
                                        NumberAnimation {
                                            from:        0
                                            to:          -(trackTitleText.implicitWidth - trackTitleText.parent.width)
                                            duration:    (trackTitleText.implicitWidth - trackTitleText.parent.width) * 30
                                            easing.type: Easing.Linear
                                        }
                                        PauseAnimation { duration: 1200 }
                                        NumberAnimation {
                                            from:        -(trackTitleText.implicitWidth - trackTitleText.parent.width)
                                            to:          0
                                            duration:    400
                                            easing.type: Easing.InOutCubic
                                        }
                                        PauseAnimation { duration: 800 }
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

                        // ── Scrubber (Slider) ──────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 4

                            Widgets.WavySlider {
                                width:    parent.width
                                progress: bigPlayer.posProgress
                                playing:  bigPlayer.player?.isPlaying ?? false

                                onSeeked: (ratio) => {
                                    const p = bigPlayer.player
                                    if (!p || p.length <= 0) return
                                    p.position            = ratio * p.length
                                    bigPlayer.posProgress = ratio
                                    bigPlayer.lastPos     = ratio * p.length
                                    bigPlayer.lastPollMs  = Date.now()
                                }
                            }
                            // Timestamps
                            Item {
                                width:  parent.width
                                height: tsLeft.implicitHeight

                                Text {
                                    id: tsLeft
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
                            spacing: 6

                            // Previous
                            ToolButton {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           "󰒮"
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 18
                                implicitWidth:  40; implicitHeight: 40
                                onClicked: bigPlayer.player?.previous()
                            }

                            // Play / Pause — RoundButton animates radius like Android
                            RoundButton {
                                id: playBtn
                                anchors.verticalCenter: parent.verticalCenter
                                width:  48; height: 48
                                radius: (bigPlayer.player?.isPlaying ?? false) ? 24 : 10

                                Behavior on radius {
                                    NumberAnimation { duration: 400; easing.type: Easing.InOutCubic }
                                }

                                text: (bigPlayer.player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 18

                                background: Rectangle {
                                    color:  Theme.Catppuccin.accent
                                    radius: playBtn.radius
                                    Behavior on radius {
                                        NumberAnimation { duration: 400; easing.type: Easing.InOutCubic }
                                    }
                                }

                                contentItem: Text {
                                    text:            playBtn.text
                                    font:            playBtn.font
                                    color:           Theme.Catppuccin.bg
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment:   Text.AlignVCenter
                                }

                                scale: 1.0
                                Behavior on scale { NumberAnimation { duration: 80 } }
                                onPressed:  scale = 0.92
                                onReleased: scale = 1.0
                                onClicked:  bigPlayer.player?.togglePlaying()
                            }

                            // Next
                            ToolButton {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           "󰒭"
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: 18
                                implicitWidth:  40; implicitHeight: 40
                                onClicked: bigPlayer.player?.next()
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
