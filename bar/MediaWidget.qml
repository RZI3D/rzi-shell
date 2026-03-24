import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root
    property var currentPlayer: null

    implicitWidth:  currentPlayer !== null ? mediaRow.implicitWidth : 0
    implicitHeight: Theme.Catppuccin.barHeight

    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Repeater {
        model: Mpris.players
        delegate: Item {
            Component.onCompleted:   { if (index === 0) root.currentPlayer = modelData }
            Component.onDestruction: { if (index === 0) root.currentPlayer = null }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        height: Theme.Catppuccin.barHeight - 10
        width:  parent.width !== 0 ? parent.width + 10 : 0
        color:  Theme.Catppuccin.surface1
        radius: 9

        // Cascade Material theming to all controls inside
        Material.theme:      Material.Dark
        Material.accent:     Theme.Catppuccin.accent
        Material.foreground: Theme.Catppuccin.fg
        Material.background: Theme.Catppuccin.surface1

        RowLayout {
            id: mediaRow
            anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
            spacing: 0
            clip: true

            // ── Play / Pause ───────────────────────────────────────────
            ToolButton {
                text:           (root.currentPlayer?.isPlaying ?? false) ? "󰏤" : "󰐊"
                font.family:    Theme.Catppuccin.font
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
                implicitWidth:  28
                implicitHeight: 28
                onClicked: root.currentPlayer?.togglePlaying()
            }

            // ── Scrolling track text ───────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitWidth:  64
                implicitHeight: trackText.implicitHeight
                clip: true

                Text {
                    id: trackText
                    text: {
                        const p = root.currentPlayer
                        if (!p) return ""
                        const t = p.trackTitle  || ""
                        const a = p.trackArtist || ""
                        return a ? `${a} — ${t}` : t
                    }
                    color:          Theme.Catppuccin.fg
                    font.family:    Theme.Catppuccin.font
                    font.pixelSize: Theme.Catppuccin.fontSm
                    anchors.verticalCenter: parent.verticalCenter

                    property bool shouldScroll: implicitWidth > parent.width
                    x: 0
                    SequentialAnimation on x {
                        running: trackText.shouldScroll
                        loops:   Animation.Infinite
                        NumberAnimation {
                            from:        0
                            to:          -(trackText.implicitWidth - trackText.parent.width)
                            duration:    (trackText.implicitWidth - trackText.parent.width) * 40
                            easing.type: Easing.Linear
                        }
                        PauseAnimation { duration: 1200 }
                        NumberAnimation {
                            from:        -(trackText.implicitWidth - trackText.parent.width)
                            to:          0
                            duration:    1200
                            easing.type: Easing.InOutCubic
                        }
                        PauseAnimation { duration: 800 }
                    }
                }
            }

            // ── Previous ───────────────────────────────────────────────
            ToolButton {
                text:           "󰒮"
                font.family:    Theme.Catppuccin.font
                font.pixelSize: 13
                implicitWidth:  26
                implicitHeight: 26
                Layout.alignment: Qt.AlignVCenter
                onClicked: root.currentPlayer?.previous()
            }

            // ── Next ───────────────────────────────────────────────────
            ToolButton {
                text:           "󰒭"
                font.family:    Theme.Catppuccin.font
                font.pixelSize: 13
                implicitWidth:  26
                implicitHeight: 26
                Layout.alignment: Qt.AlignVCenter
                onClicked: root.currentPlayer?.next()
            }
        }
    }
}
