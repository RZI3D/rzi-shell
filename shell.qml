import Quickshell
import Quickshell.Services.Notifications
import "./bar"
import "./notifications"
import "./launcher"
import "./sidebar"

ShellRoot {
    NotificationServer {
        id: notifServer
        keepOnReload: true

        onNotification: (notif) => {
            notif.tracked = true
        }
    }
    Bar {}
    NotifLayer {}
    LauncherLayer {}
    VolumeToast {}
}
