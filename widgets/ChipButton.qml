import QtQuick
import Quickshell.Widgets
import "../theme" as Theme

Rectangle {
    id: root

    // ── Public API ─────────────────────────────────────────────────────
    property string text:      ""
    property string icon:      ""
    property color  bgColor:   Theme.Catppuccin.surface0
    property color  fgColor:   Theme.Catppuccin.fg
    property int    iconSize:  22
    property int    textSize:  Theme.Catppuccin.fontMd

    property int buttonWidth:  contentRow.implicitWidth + 32
    property int buttonHeight: 52
    property int buttonRadius:         28
    property bool onLeft: false

    signal clicked()

    // ── Geometry ───────────────────────────────────────────────────────

    implicitWidth:  root.buttonWidth
    implicitHeight: root.buttonHeight
    radius:         root.buttonRadius

    color: hov ? Qt.darker(bgColor, 1.08) : bgColor
    Behavior on color { ColorAnimation { duration: 100 } }

    scale: 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }

    property bool hov: false

    // ── Content ────────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors {
            left: root.onLeft ? parent.left : undefined
            horizontalCenter: root.onLeft ? undefined : parent.horizontalCenter
        
            // Keep it vertically centered regardless
            verticalCenter: parent.verticalCenter
        
            // Add a margin only when it's on the left
            leftMargin: root.onLeft ? 20 : 0
        }
        spacing: icon !== "" && text !== "" ? 6 : 0
        
        IconImage {
            visible:        root.icon !== ""
            width: root.iconSize; height: root.iconSize
            scale: 1.0
            anchors.verticalCenter: parent.verticalCenter
            source: "image://icon/" + root.icon
        }

        Text {
            visible:        root.text !== ""
            text:           root.text
            color:          root.fgColor
            font.family:    Theme.Catppuccin.font
            font.pixelSize: root.textSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onEntered:    { root.hov = true }
        onExited:     { root.hov = false }
        onPressed:    { root.scale = 0.93 }
        onReleased:   { root.scale = 1.0 }
        onClicked:    root.clicked()
    }
}
