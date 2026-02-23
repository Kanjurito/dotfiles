import QtQuick
import Quickshell

Shell {
    property bool mediaVisible: false

    Connections {
        target: Qt.application
        function onSignalReceived(sig) {
            if (sig === "SIGUSR1") {
                mediaVisible = !mediaVisible
            }
        }
    }

    PanelWindow {
        id: mediaPlayer
        visible: mediaVisible
        anchors.centerIn: parent
        width: 500
        height: 300
        color: "#0f0f1a"
        radius: 20
        border.color: "#00f7ff"
        border.width: 2
    }
}
