import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import "../theme" as Theme

Item {
    implicitWidth: wsRow.implicitWidth
    implicitHeight: Theme.Catppuccin.barHeight

    // wsMap[id] = icon string for biggest window
    property var wsMap: ({})

    function rebuildMap() {
        const m = {};
        for (let i = 0; i < Hyprland.toplevels.count; i++) {
            const tl = Hyprland.toplevels.values[i];
            if (!tl)
                continue;
            const wsId = tl.workspace?.id;
            if (!wsId || m[wsId])
                // only first window per workspace
                continue;
            const cls = tl.lastIpcObject?.class ?? "";
            const entry = cls ? DesktopEntries.heuristicLookup(cls) : null;
            const icon = entry?.icon ?? "";
            m[wsId] = icon ? Quickshell.iconPath(icon) : "";
        }
        wsMap = m;
    }

    Component.onCompleted: rebuildMap()

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            rebuildMap();
        }
    }

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            rebuildMap();
        }
    }

    Rectangle {
        anchors.centerIn: parent
        height: Theme.Catppuccin.barHeight - 10
        width: wsRow.implicitWidth + 10
        color: Theme.Catppuccin.surface1
        radius: 9

        Row {
            id: wsRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: 9

                Rectangle {
                    required property int index
                    property int wsId: index + 1
                    property bool isFocused: Hyprland.focusedWorkspace?.id === wsId
                    property bool hasWindows: Hyprland.workspaces.values.some(ws => ws.id === wsId)
                    property string iconSrc: wsMap[wsId] ?? ""

                    anchors.verticalCenter: parent.verticalCenter
                    width: isFocused ? 28 : 20
                    height: 24
                    radius: 6
                    color: isFocused ? Theme.Catppuccin.accent : hasWindows ? Theme.Catppuccin.surface2 : Theme.Catppuccin.surface0

                    Behavior on width {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 220
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + wsId)
                    }

                    Text {
                        text: wsId
                        color: isFocused ? Theme.Catppuccin.bg : Theme.Catppuccin.fgMuted
                        font.family: Theme.Catppuccin.font
                        font.pixelSize: 6
                        font.bold: true
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            margins: 2
                        }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        source: parent.iconSrc
                        visible: parent.iconSrc !== "" && status === Image.Ready
                        width: 14
                        height: 14
                        smooth: true
                    }
                }
            }
        }
    }
}
