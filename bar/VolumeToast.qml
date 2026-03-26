import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../widgets" as Widgets

Scope {
    IpcHandler {
        target: "volumeToast"
        function toggle(): void { volToast.toggle() }
    }

    Widgets.ToastSlider {
        id: volToast
        
        readonly property var sink: Pipewire.defaultAudioSink?.audio ?? null
        readonly property bool isMuted: sink?.muted ?? false
        
        Connections {
            target: volToast.sink
            ignoreUnknownSignals: true
            function onVolumeChanged() { volToast.show() }
            function onMutedChanged() { volToast.show() }
        }

        icon: isMuted ? "image://icon/audio-volume-muted-symbolic" : "image://icon/audio-volume-high-symbolic"
        progress: sink?.volume ?? 0.0
        text: Math.round(progress * 100) + "%"
        muted: isMuted
    }
}