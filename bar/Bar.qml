import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen:        modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.Catppuccin.barHeight
            color:         "transparent"
            margins { top: 6; left: 6; right: 6 }
            
            WlrLayershell.namespace: "quickshell:bar"

            Rectangle {
                anchors.fill: parent
                color:        Theme.Catppuccin.bgFloat
                radius:       Theme.Catppuccin.radius

                // Left and right only in the layout
                RowLayout {
                    anchors { fill: parent; margins: Theme.Catppuccin.spacing;}
                    spacing: 0
                    Workspaces { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                    Item { Layout.fillWidth: true }
                    SysTray { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                }
                
                // Clock + media absolutely centered on the bar
                Row {
                    anchors.centerIn: parent
                    spacing: Theme.Catppuccin.spacing + 10
                    Clock       { anchors.verticalCenter: parent.verticalCenter }
                    MediaWidget { anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }
}