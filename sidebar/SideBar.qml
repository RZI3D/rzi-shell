import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../theme" as Theme
import "../sidebar" as Sidebar

Scope {
    id: root
    function toggle() { Sidebar.SideBarState.toggle() }


    IpcHandler {
        target: "sidebar"
        function toggle(): void { Sidebar.SideBarState.toggle() }
    }

    PanelWindow {
        id: sidebarPopup
        visible: Sidebar.SideBarState.open
        anchors { top: true; right: true; bottom: true; left: true }
        color: "transparent"

        WlrLayershell.namespace:     "quickshell:sidebar"
        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Keys.onEscapePressed: panel.closePanel()

        MouseArea {
            anchors.fill: parent
            onClicked: panel.closePanel()
            enabled: Sidebar.SideBarState.open
        }

        Rectangle {
            id: panel
            anchors {
                top:    parent.top
                // right:  parent.right
                bottom: parent.bottom
                topMargin:    4
                rightMargin:  8
                bottomMargin: 4
            }
            width: 360

            radius:       Theme.Catppuccin.radius
            color:        Theme.Catppuccin.bgFloat
            border.color: Theme.Catppuccin.border
            border.width: 1

            Material.theme:      Material.Dark
            Material.accent:     Theme.Catppuccin.accent
            Material.foreground: Theme.Catppuccin.fg
            Material.background: Theme.Catppuccin.bgFloat

            function closePanel() {
                closeAnim.start()
            }

            NumberAnimation {
                id: closeAnim
                target: panel
                property: "x"
                to: panel.parent.width + 12
                duration: 220
                easing.type: Easing.OutCubic
                onFinished: {
                    Sidebar.SideBarState.open = !Sidebar.SideBarState.open
                }
            }

            x: Sidebar.SideBarState.open ? panel.parent.width - panel.width - 8 : x
            Behavior on x {
                enabled: Sidebar.SideBarState.open  // only animate open, not close
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }


            MouseArea { anchors.fill: parent; enabled: Sidebar.SideBarState.open }

            ColumnLayout {
                anchors { fill: parent; margins: 14 }
                spacing: 10

                // ── Header ─────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text:           "Notifications"
                        color:          Theme.Catppuccin.fg
                        font.family:    Theme.Catppuccin.font
                        font.pixelSize: Theme.Catppuccin.fontLg
                        font.bold:      true
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Clear all"
                        flat: true
                        visible: notifList.count > 0
                        Material.foreground: Theme.Catppuccin.fgDim
                        onClicked: {
                            // expire all tracked notifications
                            for (let i = notifServer.trackedNotifications.count - 1; i >= 0; i--) {
                                notifServer.trackedNotifications.values[i].expire()
                            }
                        }
                    }
                }

                // ── Divider ────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color:  Theme.Catppuccin.border
                }

                // ── Notification list ──────────────────────────────
                ScrollView {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Column {
                        id: notifList
                        width: parent.width
                        spacing: 8
                        property int count: notifRepeater.count

                        // Empty state
                        Item {
                            visible: notifRepeater.count === 0
                            width:   parent.width
                            height:  120

                            Text {
                                anchors.centerIn: parent
                                text:           "No notifications"
                                color:          Theme.Catppuccin.fgDim
                                font.family:    Theme.Catppuccin.font
                                font.pixelSize: Theme.Catppuccin.fontMd
                            }
                        }

                        Repeater {
                            id: notifRepeater
                            model: notifServer.trackedNotifications

                            SideNotifCard {
                                required property var modelData
                                notif: modelData
                                width: notifList.width
                            }
                        }
                    }
                }
            }
        }
    }
}