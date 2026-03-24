import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../theme" as Theme

Scope {
    property bool open: false
    property var sortedApps: []

    Instantiator {
        id: appInstantiator
        model: DesktopEntries.applications
        delegate: QtObject {
            required property DesktopEntry modelData
        }
    }

    function rebuildApps() {
        const arr = []
        for (let i = 0; i < appInstantiator.count; i++) {
            const obj = appInstantiator.objectAt(i)
            if (obj) arr.push(obj.modelData)
        }
        arr.sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""))
        sortedApps = arr
    }

    onOpenChanged: {
        if (open) {
            rebuildApps()
        } else {
            sortedApps = []
        }
    }

    IpcHandler {
        target: "launcher"
        function toggleLauncher() { open = !open }
    }

    PanelWindow {
        visible: open
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        WlrLayershell.namespace:     "quickshell:launcher"
        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Keys.onEscapePressed: open = false

        MouseArea {
            anchors.fill: parent
            onClicked: open = false
        }

        Rectangle {
            id: panel
            width:  500
            height: 540
            anchors.centerIn: parent
            radius: Theme.Catppuccin.radius
            color:  Theme.Catppuccin.bg
            border.color: Theme.Catppuccin.accent
            border.width: 1

            // Cascade Material theming to all controls inside
            Material.theme:      Material.Dark
            Material.accent:     Theme.Catppuccin.accent
            Material.foreground: Theme.Catppuccin.fg
            Material.background: Theme.Catppuccin.bg

            scale:   open ? 1.0 : 0.92
            opacity: open ? 1.0 : 0.0
            Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors { fill: parent; margins: 12 }
                spacing: 8

                // ── Search bar ─────────────────────────────────────────
                TextField {
                    id: searchBox
                    Layout.fillWidth: true
                    placeholderText:  "Search apps..."

                    leftInset:   0; rightInset:  0
                    topInset:    0; bottomInset: 0
                    leftPadding: 36

                    font.family:    Theme.Catppuccin.font
                    font.pixelSize: Theme.Catppuccin.fontMd

                    background: Rectangle {
                        radius: Theme.Catppuccin.radiusSm
                        color:  Theme.Catppuccin.surface0
                        // No underline / Material decoration
                    }

                    onVisibleChanged: if (visible) {
                        forceActiveFocus()
                        text = ""
                        appList.currentIndex = 0
                    }

                    Keys.onEscapePressed: open = false

                    Keys.onUpPressed: {
                        let prev = appList.currentIndex - 1
                        while (prev >= 0 && !appList.itemAtIndex(prev)?.visible) prev--
                        if (prev >= 0) appList.currentIndex = prev
                    }
                    Keys.onDownPressed: {
                        let next = appList.currentIndex + 1
                        while (next < appList.count && !appList.itemAtIndex(next)?.visible) next++
                        if (next < appList.count) appList.currentIndex = next
                    }
                    Keys.onReturnPressed: {
                        const item = appList.itemAtIndex(appList.currentIndex)
                        if (item) item.triggerLaunch()
                    }

                    // Search icon
                    Text {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        text:           "󰍉"
                        color:          Theme.Catppuccin.fgMuted
                        font.family:    Theme.Catppuccin.font
                        font.pixelSize: 14
                    }
                }

                // ── App list ───────────────────────────────────────────
                ListView {
                    id: appList
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    clip:         true
                    spacing:      0
                    currentIndex: 0
                    model:        sortedApps

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: ItemDelegate {
                        id: appItem
                        required property var modelData
                        required property int index

                        width:   ListView.view.width
                        height:  visible ? 56 : 0
                        visible: modelData.name.toLowerCase().includes(searchBox.text.toLowerCase())
                            ||   (modelData.genericName ?? "").toLowerCase().includes(searchBox.text.toLowerCase())

                        highlighted: ListView.isCurrentItem

                        // Override highlight color to Catppuccin surface
                        background: Rectangle {
                            radius: Theme.Catppuccin.radiusSm
                            color:  appItem.highlighted ? Theme.Catppuccin.surface1
                                :   appItem.hovered     ? Theme.Catppuccin.surface0
                                :                         "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }
                        }

                        function triggerLaunch() {
                            appItem.modelData.execute()
                            open = false
                        }

                        onClicked: triggerLaunch()
                        onHoveredChanged: if (hovered) appList.currentIndex = index

                        contentItem: RowLayout {
                            spacing: 10

                            IconImage {
                                source:  appItem.modelData.icon !== "" ? "image://icon/" + appItem.modelData.icon : ""
                                visible: appItem.modelData.icon !== "" && status === Image.Ready
                                width:   32; height: 32
                                smooth:  true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text:           appItem.modelData.name
                                    color:          Theme.Catppuccin.fg
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: Theme.Catppuccin.fontMd
                                    elide:          Text.ElideRight
                                    width:          parent.width
                                }
                                Text {
                                    text:           appItem.modelData.genericName ?? appItem.modelData.comment ?? ""
                                    visible:        text !== ""
                                    color:          Theme.Catppuccin.fgMuted
                                    font.family:    Theme.Catppuccin.font
                                    font.pixelSize: Theme.Catppuccin.fontSm
                                    elide:          Text.ElideRight
                                    width:          parent.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
