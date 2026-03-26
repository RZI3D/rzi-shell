import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "../theme" as Theme

Rectangle {
    id: card
    required property Notification notif

    width: parent.width
    height: layout.implicitHeight + 20
    radius: Theme.Catppuccin.radius
    color:  Theme.Catppuccin.surface0
    border.color: Theme.Catppuccin.border
    border.width: 1

    Material.theme:      Material.Dark
    Material.foreground: Theme.Catppuccin.fg
    Material.background: Theme.Catppuccin.surface0

    ColumnLayout {
        id: layout
        anchors { fill: parent; margins: 12 }
        spacing: 8

        // ── Header ─────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Image {
                source:   card.notif.appIcon || ""
                visible:  card.notif.appIcon !== ""
                width:    16; height: 16
                smooth:   true
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text:           card.notif.appName
                color:          Theme.Catppuccin.accent
                font.family:    Theme.Catppuccin.font
                font.pixelSize: Theme.Catppuccin.fontSm
                font.bold:      true
                Layout.fillWidth: true
            }

            Text {
                text:      "✕"
                color:     Theme.Catppuccin.fgDim
                font.pixelSize: 13
                Layout.alignment: Qt.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.notif.expire()
                }
            }
        }

        // ── Summary ────────────────────────────────────────────────
        Text {
            text:           card.notif.summary
            color:          Theme.Catppuccin.fg
            font.family:    Theme.Catppuccin.font
            font.pixelSize: Theme.Catppuccin.fontMd
            font.bold:      true
            wrapMode:       Text.WordWrap
            Layout.fillWidth: true
        }

        // ── Body ───────────────────────────────────────────────────
        Text {
            visible:        card.notif.body !== ""
            text:           card.notif.body
            color:          Theme.Catppuccin.fgMuted
            font.family:    Theme.Catppuccin.font
            font.pixelSize: Theme.Catppuccin.fontSm
            wrapMode:       Text.WordWrap
            textFormat:     Text.PlainText
            Layout.fillWidth: true
        }

        // ── Actions ────────────────────────────────────────────────
        Flow {
            visible:    card.notif.actions.length > 0
            spacing:    6
            Layout.fillWidth: true

            Repeater {
                model: card.notif.actions

                Button {
                    required property var modelData
                    text:    modelData.text
                    flat:    true
                    Material.foreground: Theme.Catppuccin.accent
                    onClicked: {
                        modelData.invoke()
                        card.notif.expire()
                    }
                }
            }
        }
    }
}