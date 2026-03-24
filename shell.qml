// Entry point — launched via: quickshell -p rzi
import Quickshell
import "./bar"
import "./notifications"
import "./launcher"

ShellRoot {
    Bar {}
    NotifLayer {}
    LauncherLayer {}
}
