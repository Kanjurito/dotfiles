import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: shellRoot

    NetworkDashboard { id: dashWindow }

    IpcHandler {
        target: "toggle"
        function onMessage() {
            dashWindow.visible = !dashWindow.visible
        }
    }
}
