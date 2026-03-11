import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    ControlCenter { id: cc }

    IpcHandler {
        target: "toggle"
        function onMessage() { cc.visible = !cc.visible }
    }
}
