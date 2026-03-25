import QtQuick
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

    signal clicked()

    // ── Geometry ───────────────────────────────────────────────────────
    implicitWidth:  contentRow.implicitWidth + 32
    implicitHeight: 52
    radius:         28

    color: hov ? Qt.darker(bgColor, 1.08) : bgColor
    Behavior on color { ColorAnimation { duration: 100 } }

    scale: 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }

    property bool hov: false

    // ── Content ────────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: icon !== "" && text !== "" ? 6 : 0

        Text {
            visible:        root.icon !== ""
            text:           root.icon
            color:          root.fgColor
            font.family:    Theme.Catppuccin.font
            font.pixelSize: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
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
