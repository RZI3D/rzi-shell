pragma Singleton
import QtQuick

QtObject {
    property var barWindow: null  // ← set this from Bar.qml
    property bool open: false
    property bool dndEnabled: false
    signal closeRequested()

    function toggle() {
        if (open) closeRequested()
        else open = true
    }
}