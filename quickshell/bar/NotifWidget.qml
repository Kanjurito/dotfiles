import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: 46

    property string notifState: "none"

    property string currentIcon: {
        switch (notifState) {
            case "notification":     return "󱅫"
            case "dnd-notification": return "󱅫"
            case "dnd-none":         return "󰂛"
            default:                 return "󰂚"
        }
    }

    Process {
        id: swayncWatcher
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const data = JSON.parse(line)
                    root.notifState = data.text ?? "none"
                } catch (_) {
                    root.notifState = line.trim()
                }
            }
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 24
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.05)
            visible: mouse.containsMouse
        }

        Text {
            anchors.centerIn: parent
            text: root.currentIcon
            color: "#f38ba8"
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Quickshell.execDetached(["sh", "-c", "swaync-client -t -sw"])
    }

    scale: mouse.pressed ? 0.88 : 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }
}
