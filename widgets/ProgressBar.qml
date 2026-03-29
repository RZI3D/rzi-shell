import QtQuick
import "../theme" as Theme

Item {
    id: root
    property real progress: 0.5 
    property color color: Theme.Catppuccin.accent
    property color color2: Theme.Catppuccin.surface0
    property bool disableAnimation: false
    property real gap: 4

    implicitWidth: 200
    implicitHeight: 48

    // ── Full Width Container ──────────────────────────────────────────
    Item {
        anchors.centerIn: parent
        width: parent.width
        height: 4 

        // ── Left Side (Filled) ────────────────────────────────────────
        Rectangle {
            id: fillRect
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            
            // The width is the total progress minus half the gap
            // We use Math.max to ensure width doesn't go negative
            width: Math.max(0, (parent.width * root.progress) - (root.gap / 2))
            height: parent.height
            color: root.color
            radius: height / 2

            Behavior on width { enabled: !root.disableAnimation; NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        }

        // ── Right Side (Unfilled) ──────────────────────────────────────
        Rectangle {
            id: emptyRect
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            
            // The width starts where the gap ends
            width: Math.max(0, (parent.width * (1.0 - root.progress)) - (root.gap / 2))
            height: parent.height
            color: root.color2
            radius: height / 2

            Behavior on width { enabled: !root.disableAnimation; NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        }
    }
}