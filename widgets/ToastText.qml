import QtQuick
import Quickshell

Toast {
    property alias icon: txtIcon.name
    property alias iconColor: txtIcon.color
    property alias title: titleLabel.text
    property alias subtitle: subLabel.text

    Row {
        anchors.centerIn: parent
        spacing: 16

        Icon {
            id: txtIcon
            width: 32; height: 32
            color: iconColor // Default to passed color
        }

        Column {
            Text {
                id: titleLabel
                color: Theme.Catppuccin.fg
                font.pixelSize: 14; font.weight: Font.Bold
            }
            Text {
                id: subLabel
                color: Theme.Catppuccin.overlay0
                font.pixelSize: 12
            }
        }
    }
}