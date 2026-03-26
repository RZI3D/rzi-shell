import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
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
                    PopupWindow {
                        id: menuPopup
                        anchor.window: topBar
                        anchor.gravity: Edges.Bottom
                        anchor.edges: Edges.Bottom
                        color: "transparent"
                        visible: false
                        grabFocus: true
                        implicitWidth: 220
                        implicitHeight: menuStack.currentItem ? menuStack.currentItem.implicitHeight : 0

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.Catppuccin.surface0
                            radius: 6
                            border.color: Theme.Catppuccin.surface2
                            border.width: 1
                            clip: true

                            Material.theme:      Material.Dark
                            Material.accent:     Theme.Catppuccin.accent
                            Material.foreground: Theme.Catppuccin.fg
                            Material.background: Theme.Catppuccin.bgFloat
                            
                            StackView {
                                id: menuStack
                                anchors.fill: parent

                                pushEnter: Transition { NumberAnimation { duration: 0 } }
                                pushExit: Transition { NumberAnimation { duration: 0 } }
                                popEnter: Transition { NumberAnimation { duration: 0 } }
                                popExit: Transition { NumberAnimation { duration: 0 } }
                            }
                        }
                    }

                    // Submenu component — referenced by StackView.push()
                    Component {
                        id: subMenuComp

                        Column {
                            id: subMenuCol
                            property QsMenuHandle handle
                            property bool isSubMenu: false
                            width: parent ? parent.width : 220
                            padding: 4
                            spacing: 0

                            QsMenuOpener {
                                id: opener
                                menu: subMenuCol.handle
                            }

                            Repeater {
                                model: opener.children

                                delegate: Item {
                                    id: entryItem
                                    required property QsMenuEntry modelData
                                    width: subMenuCol.width - subMenuCol.padding * 2
                                    implicitHeight: modelData.isSeparator ? 9 : entryDelegate.implicitHeight

                                    // Separator
                                    Rectangle {
                                        visible: entryItem.modelData.isSeparator
                                        anchors.centerIn: parent
                                        width: parent.width - 16
                                        height: 1
                                        color: Theme.Catppuccin.surface2
                                    }

                                    // Menu item
                                    ItemDelegate {
                                        id: entryDelegate
                                        visible: !entryItem.modelData.isSeparator
                                        width: parent.width
                                        text: entryItem.modelData.text
                                        enabled: entryItem.modelData.enabled
                                        icon.source: entryItem.modelData.icon
                                        icon.color: "transparent"
                                        Material.foreground: entryItem.modelData.enabled
                                            ? Theme.Catppuccin.text
                                            : Theme.Catppuccin.surface0

                                        onClicked: {
                                            if (entryItem.modelData.hasChildren) {
                                                menuStack.push(subMenuComp, {
                                                    handle: entryItem.modelData,
                                                    isSubMenu: true
                                                })
                                            } else {
                                                entryItem.modelData.triggered()
                                                menuPopup.visible = false
                                            }
                                        }
                                    }
                                }
                            }

                            // Back button for submenus
                            ItemDelegate {
                                visible: subMenuCol.isSubMenu
                                width: subMenuCol.width - subMenuCol.padding * 2
                                text: "← Back"
                                Material.foreground: Theme.Catppuccin.subtext0
                                onClicked: menuStack.pop()
                            }
                        }
                    }

                    ToolButton {
                        anchors.centerIn: parent
                        width: 32; height: 32
                        icon.source: trayItem.modelData.icon
                        icon.width: 16
                        icon.height: 16
                        icon.color: "transparent"
                        Material.foreground: Theme.Catppuccin.text

                        onClicked: trayItem.modelData.activate()

                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: {
                                if (trayItem.modelData.hasMenu) {
                                    const p = trayItem.mapToGlobal(0, 0)
                                    menuPopup.anchor.rect = Qt.rect(p.x, p.y, trayItem.width, trayItem.height)
                                    menuStack.clear()
                                    menuStack.push(subMenuComp, { handle: trayItem.modelData.menu })
                                    menuPopup.visible = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}