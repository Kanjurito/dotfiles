import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    UserMenu { id: menuWindow }

    IpcHandler {
        target: "toggle"
        function onMessage() {
            menuWindow.visible = !menuWindow.visible
        }
    }
}
