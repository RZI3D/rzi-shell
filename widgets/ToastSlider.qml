import QtQuick
import Quickshell
import Quickshell.Widgets
import "." as LocalWidgets
import "../theme" as Theme

LocalWidgets.Toast {
    id: sliderRoot
    
    property alias icon: volIcon.source
    property alias progress: bar.progress
    property alias text: label.text
    property bool muted: false
    property bool disableAnimation: false
    property color barColor: sliderRoot.muted ? Theme.Catppuccin.overlay0 : Theme.Catppuccin.accent
    property color barColor2: Theme.Catppuccin.surface0
    property color textColor: sliderRoot.muted ? Theme.Catppuccin.overlay0 : Theme.Catppuccin.fg 

    Row {
        anchors.centerIn: parent
        spacing: 16

        IconImage {
            id: volIcon
            width: 26; height: 26
            scale: 1.0
            anchors.verticalCenter: parent.verticalCenter
            onSourceChanged: iconBounce.start()
            
            SequentialAnimation {
                id: iconBounce
                NumberAnimation { target: volIcon; property: "scale"; to: 0.8; duration: 50 }
                NumberAnimation { target: volIcon; property: "scale"; to: 1.2; duration: 100; easing.type: Easing.OutBack }
                NumberAnimation { target: volIcon; property: "scale"; to: 1.0; duration: 50 }
            }
        }

        LocalWidgets.ProgressBar {
            id: bar
            width: 160; height: 8
            anchors.verticalCenter: parent.verticalCenter
            color: sliderRoot.barColor
            color2: sliderRoot.barColor2
            disableAnimation: sliderRoot.disableAnimation
        }

        Text {
            id: label
            width: 40
            anchors.verticalCenter: parent.verticalCenter
            color: sliderRoot.textColor
            font.pixelSize: 14; font.weight: Font.DemiBold; font.family: "JetBrains Mono"
            horizontalAlignment: Text.AlignRight
        }
    }
}