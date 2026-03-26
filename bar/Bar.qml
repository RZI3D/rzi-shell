import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "../theme" as Theme
import "../widgets" as Widgets
import "../sidebar" as Sidebar  // ← add this

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            id: "topBar"
            screen:        modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.Catppuccin.barHeight
            color:         "transparent"
            margins { top: 6; left: 6; right: 6 }
            WlrLayershell.namespace: "quickshell:bar"

            CenterPopup {
                id: centerPopup
            }
            Sidebar.SideBar { id: sideBar }
            Rectangle {
                anchors.fill: parent
                color:        Theme.Catppuccin.bgFloat
                radius:       Theme.Catppuccin.radius
                border.color: Theme.Catppuccin.border
                border.width: 1


                // Left and right only in the layout
                RowLayout {
                    anchors { fill: parent; margins: Theme.Catppuccin.spacing;}
                    spacing: Theme.Catppuccin.spacing
                    Workspaces { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                    Item { Layout.fillWidth: true }
                    Widgets.BatteryIndicator  { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }  // ← add
                    SysTray { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                    ToolButton {
                        Layout.alignment: Qt.AlignVCenter
                        icon.name: "notification-symbolic"
                        icon.color: "transparent"
                        implicitWidth: 28; implicitHeight: 28
                        Material.foreground: Theme.Catppuccin.fg
                        onClicked: Sidebar.SideBarState.toggle()  // via IPC alternatively: Quickshell.ipc("sidebar", "toggle")
                    }
                }
                
                // Clock + media absolutely centered on the bar
                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.Catppuccin.spacing + 10
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: centerPopup.toggle()
                    }
                    Clock       { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                    MediaWidget { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }

                }
            }
        }
    }
}