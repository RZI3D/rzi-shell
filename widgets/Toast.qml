import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme" as Theme

PopupWindow {
    id: root

    property int openHeight: 75
    property int closeHeight: 0
    property int toastWidth: 310

    default property alias content: container.data

    parentWindow: topBar

    visible: false
    implicitWidth: toastWidth
    implicitHeight: closeHeight
    color: "transparent"

    anchor.window: topBar
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.rect.x: Math.round((topBar.width - toastWidth) / 2)
    anchor.rect.y: 0
    anchor.adjustment: PopupAdjustment.None

    function show() {
        openAnim.start()
        visible = true
        hideTimer.restart()
    }

    function toggle() {
        if (visible && implicitHeight > 0) closeAnim.start()
        else show()
    }

    NumberAnimation { id: openAnim;  target: root; property: "implicitHeight"; to: root.openHeight;  duration: 250; easing.type: Easing.OutCubic }
    NumberAnimation { id: closeAnim; target: root; property: "implicitHeight"; to: root.closeHeight; duration: 200; easing.type: Easing.OutCubic; onFinished: root.visible = false }
    Timer { id: hideTimer; interval: 2200; onTriggered: closeAnim.start() }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.toastWidth
        height: 52
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