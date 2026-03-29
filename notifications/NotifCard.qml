import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

    NumberAnimation { id: fadeOut; target: card; property: "x"; to: 400; duration: 300; easing.type: Easing.OutCubic; onFinished: closeGap.start() }        
    NumberAnimation { id: closeGap; target: card; property: "height"; to: 0; duration: 200; easing.type: Easing.OutCubic; onFinished: card.notif.dismiss() }

    NumberAnimation { id: ignoreOut; target: card; property: "x"; to: 400; duration: 300; easing.type: Easing.OutCubic; onFinished: ignoreCloseGap.start() }        
    NumberAnimation { id: ignoreCloseGap; target: card; property: "height"; to: 0; duration: 200; easing.type: Easing.OutCubic; onFinished: card.visible = false }

    opacity: 0; x: 20
    Component.onCompleted: {
        if (notif.lastGeneration) {
            visible = false
        } else {
            opacity = 1
            x = 0
        }
    }
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on x       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; bottomMargin: 1; leftMargin: 1 }
        height: 3; radius: 2
        color:  Theme.Catppuccin.accent
        NumberAnimation on width {
            running:  !notif.lastGeneration
            from:     card.width - 2; to: 0
            duration: notif.expireTimeout > 0 ? notif.expireTimeout : 5000
            onFinished: ignoreOut.start()
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

        ToolButton {
            text: "✕"; //color: Theme.Catppuccin.fgDim; font.pixelSize: 13
            Layout.alignment: Qt.AlignTop
            onClicked: fadeOut.start()
            //MouseArea { anchors.fill: parent; onClicked: notif.expire() }
        }
    }
}
