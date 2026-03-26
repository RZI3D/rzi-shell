pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    property var barWindow: null  // ← set this from Bar.qml
    function toggle() { 
        if (open) {
            SideBar.SidebarPopup.panel.closePanel()
        } else {
            open = !open
        }
    }
}