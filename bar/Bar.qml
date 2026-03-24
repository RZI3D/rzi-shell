import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: rootBar // Important: ID for the popup to anchor to
            property var modelData: modelData

            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.Catppuccin.barHeight
            margins { top: 6; left: 6; right: 6 }
            
            WlrLayershell.namespace: "quickshell:bar"

            Rectangle {
                anchors.fill: parent
                color: Theme.Catppuccin.bgFloat
                radius: Theme.Catppuccin.radius

                RowLayout {
                    anchors { fill: parent; margins: Theme.Catppuccin.spacing }
                    spacing: 0
                    Workspaces { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                    Item { Layout.fillWidth: true }
                    SysTray { Layout.alignment: Qt.AlignVCenter; Layout.fillHeight: true }
                }
                
                // The Island (Trigger)
                Item {
                    anchors.centerIn: parent
                    width: centerRow.width
                    height: parent.height

                    Row {
                        id: centerRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.Catppuccin.spacing + 10
                        Clock { anchors.verticalCenter: parent.verticalCenter }
                        MediaWidget { anchors.verticalCenter: parent.verticalCenter }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: islandPopup.visible = !islandPopup.visible
                    }
                }
            }

            // Instantiate your external file here
            CenterPopup {
                id: islandPopup
                parentWindow: rootBar
            }
        }
    }
}