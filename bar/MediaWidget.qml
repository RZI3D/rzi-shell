import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root
    property var currentPlayer: null

    visible:        currentPlayer !== null
    implicitWidth:  visible ? mediaRow.implicitWidth + 16 : 0
    implicitHeight: Theme.Catppuccin.barHeight

    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // Grab first player from the model
    Repeater {
        model: Mpris.players
        delegate: Item {
            Component.onCompleted: { if (index === 0) root.currentPlayer = modelData }
            Component.onDestruction: { if (index === 0) root.currentPlayer = null }
        }
    }

    Rectangle {
        
        // For the box around the actual thing
        anchors.centerIn: parent
        height: Theme.Catppuccin.barHeight -10
        width: parent.width + 10
        color: Theme.Catppuccin.surface1
        radius: 9

        RowLayout {
            id: mediaRow
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            spacing: 6

            Text {
                text:           (root.currentPlayer?.isPlaying ?? false) ? "󰏤" : "󰐊"
                color:          Theme.Catppuccin.accent
                font.family:    Theme.Catppuccin.font
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.currentPlayer?.togglePlaying()
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight:   trackText.implicitHeight
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

                    property bool shouldScroll: implicitWidth > 160
                    x: 0
                    NumberAnimation on x {
                        running:  trackText.shouldScroll
                        loops:    Animation.Infinite
                        from:     0
                        to:       -(trackText.implicitWidth - 160)
                        duration: trackText.implicitWidth > 160 ? (trackText.implicitWidth - 160) * 30 : 1
                    }
                }
            }

            Text {
                text: "󰒮"
                color: Theme.Catppuccin.fgMuted; font.family: Theme.Catppuccin.font; font.pixelSize: 13
                MouseArea { anchors.fill: parent; onClicked: root.currentPlayer?.previous() }
            }
            Text {
                text: "󰒭"
                color: Theme.Catppuccin.fgMuted; font.family: Theme.Catppuccin.font; font.pixelSize: 13
                MouseArea { anchors.fill: parent; onClicked: root.currentPlayer?.next() }
            }
        }
    }
}
