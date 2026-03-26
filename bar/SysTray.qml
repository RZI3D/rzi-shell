import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls.Material
import "../theme" as Theme

Item {
    implicitWidth: trayRow.implicitWidth
    implicitHeight: Theme.Catppuccin.barHeight

    Rectangle {
        anchors.centerIn: parent
        height: Theme.Catppuccin.barHeight - 10
        width: parent.width === 0 ? 0 : parent.width + 10
        color: Theme.Catppuccin.surface1
        radius: 9
        Material.theme:      Material.Dark
        Material.accent:     Theme.Catppuccin.accent
        Material.foreground: Theme.Catppuccin.fg
        Material.background: Theme.Catppuccin.bgFloat
        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: SystemTray.items

                Item {
                    id: trayItem
                    required property SystemTrayItem modelData
                    width: 22; height: 22

                    QsMenuAnchor {
                        id: contextMenu
                        anchor.window: topBar
                        menu: modelData.menu
                    }

                    ToolButton {
                        anchors.centerIn: parent
                        width: 32; height: 32
                        icon.source: modelData.icon
                        icon.width: 16
                        icon.height: 16
                        icon.color: "transparent"
                        Material.foreground: Theme.Catppuccin.text

                        onClicked: modelData.activate()

                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: (eventPoint) => {
                                if (modelData.hasMenu) {
                                    let pos = topBar.itemPosition(trayItem)
                                    modelData.display(topBar, pos.x + eventPoint.position.x, pos.y + eventPoint.position.y + 10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}