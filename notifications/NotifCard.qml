import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Rectangle {
    id: card
    required property var notif

    width:  344
    height: layout.implicitHeight + 20
    radius: Theme.Catppuccin.radius
    color:  Theme.Catppuccin.bgAlt
    border.color: Theme.Catppuccin.border
    border.width: 1

    opacity: 0; x: 20
    Component.onCompleted: { opacity = 1; x = 0 }
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on x       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; bottomMargin: 1; leftMargin: 1 }
        height: 3; radius: 2
        color:  Theme.Catppuccin.accent
        NumberAnimation on width {
            running:  true
            from:     card.width - 2; to: 0
            duration: notif.expireTimeout > 0 ? notif.expireTimeout : 5000
            onFinished: notif.expire()
        }
    }

    RowLayout {
        id: layout
        anchors { fill: parent; margins: 10 }
        spacing: 8

        Image {
            source:   notif.appIcon || ""
            visible:  notif.appIcon !== ""
            width:    28; height: 28
            smooth:   true; fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignTop
        }

        Column {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text:           notif.appName
                color:          Theme.Catppuccin.accent
                font.family:    Theme.Catppuccin.font
                font.pixelSize: Theme.Catppuccin.fontSm
                font.bold:      true
            }
            Text {
                text:           notif.summary
                color:          Theme.Catppuccin.fg
                font.family:    Theme.Catppuccin.font
                font.pixelSize: Theme.Catppuccin.fontMd
                wrapMode:       Text.WordWrap; width: parent.width
            }
            Text {
                visible:        notif.body !== ""
                text:           notif.body
                color:          Theme.Catppuccin.fgMuted
                font.family:    Theme.Catppuccin.font
                font.pixelSize: Theme.Catppuccin.fontSm
                wrapMode:       Text.WordWrap; width: parent.width
                maximumLineCount: 3; elide: Text.ElideRight
            }
        }

        Text {
            text: "✕"; color: Theme.Catppuccin.fgDim; font.pixelSize: 13
            Layout.alignment: Qt.AlignTop
            MouseArea { anchors.fill: parent; onClicked: notif.expire() }
        }
    }
}
