import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme" as Theme
import "../sidebar" as Sidebar

Scope {

    PanelWindow {
        visible: !Sidebar.SideBarState.dndEnabled
        anchors { top: true; right: true }
        margins { top: 8; right: 8 }
        implicitWidth:  360
        implicitHeight: stack.implicitHeight + 8
        color:  "transparent"

        WlrLayershell.namespace: "quickshell:notifications"
        WlrLayershell.layer: WlrLayer.Overlay

        Column {
            id: stack
            anchors { top: parent.top; right: parent.right }
            spacing: 6

            Repeater {
                model: notifServer.trackedNotifications
                delegate: NotifCard {
                    required property var modelData
                    notif: modelData
                }
            }
        }
    }
}