import QtQuick
import Quickshell
import Quickshell.Widgets
import "../theme" as Theme
import "." as LocalWidgets

LocalWidgets.Toast {
    property alias icon: txtIcon.source
    property alias title: titleLabel.text
    property alias subtitle: subLabel.text

    Row {
        anchors.centerIn: parent
        spacing: 16

        IconImage {
            id: txtIcon
            width: 32; height: 32
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