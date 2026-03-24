import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import "../theme" as Theme

PopupWindow {
    id: popup
    
    property var parentWindow
    anchor.window: parentWindow
    
    // Using simple centering logic
    anchor.rect.x: parentWindow ? (parentWindow.width / 2) - (width / 2) : 0
    anchor.rect.y: parentWindow ? parentWindow.height + 5 : 0
    
    width: 320
    height: 400
    visible: false

    Rectangle {
        anchors.fill: parent
        color: Theme.Catppuccin.bgFloat
        radius: Theme.Catppuccin.radius
        border.color: Theme.Catppuccin.bgSecondary
        border.width: 1

        // Use a MouseArea to prevent clicks from "falling through" to windows behind
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 20

            // --- Media Player ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                property var player: Mpris.players.length > 0 ? Mpris.players[0] : null

                Text {
                    text: parent.player ? parent.player.trackTitle : "No Media Playing"
                    color: Theme.Catppuccin.fg
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15
                    
                    Button { 
                        text: "󰒮"; flat: true; 
                        onClicked: if (Mpris.players.length > 0) Mpris.players[0].previous() 
                    }
                    Button { 
                        text: (Mpris.players.length > 0 && Mpris.players[0].playbackState === Mpris.Playing) ? "󰏤" : "󰐊"
                        onClicked: if (Mpris.players.length > 0) Mpris.players[0].togglePlaying()
                    }
                    Button { 
                        text: "󰒭"; flat: true; 
                        onClicked: if (Mpris.players.length > 0) Mpris.players[0].next() 
                    }
                }
            }

            // --- Calendar ---
            MonthGrid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                locale: Qt.locale("en_US")
                
                delegate: Text {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.day
                    color: model.month === month ? Theme.Catppuccin.fg : Theme.Catppuccin.bgSecondary
                    font.pixelSize: 12
                }
            }
        }
    }
}