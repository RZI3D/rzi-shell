import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme" as Theme
PanelWindow {
    id: root
    property int openHeight: 75
    property int toastWidth: 310
    
    // This allows children to inject their Rows/Columns directly
    default property alias content: container.data

    visible: false
    implicitHeight: 0
    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:volumeToast"
    WlrLayershell.layer:     WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    function show() {
        openAnim.start()
        visible = true
        hideTimer.restart()
    }

    function toggle() {
        if (visible && implicitHeight > 0) closeAnim.start()
        else show()
    }

    NumberAnimation { id: openAnim; target: root; property: "implicitHeight"; to: root.openHeight; duration: 250; easing.type: Easing.OutCubic }
    NumberAnimation { id: closeAnim; target: root; property: "implicitHeight"; to: 0; duration: 200; easing.type: Easing.InCubic; onFinished: root.visible = false }
    Timer { id: hideTimer; interval: 2200; onTriggered: closeAnim.start() }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        anchors.topMargin: 12
        height: 52
        width: root.toastWidth
        radius: Theme.Catppuccin.radius
        color:  Theme.Catppuccin.bgFloat
        border.color: Theme.Catppuccin.border
        border.width: 1

        Item {
            id: container
            anchors.centerIn: parent
        }
    }
}