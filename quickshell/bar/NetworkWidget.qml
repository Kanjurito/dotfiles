import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: 46

    // "wifi", "ethernet", "disconnected"
    property string netType: "disconnected"

    property string netIcon: {
        switch (netType) {
            case "wifi":       return ""
            case "ethernet":   return "󰈀"
            default:           return "󰖪"
        }
    }

    function refreshNetwork() {
        netProc.running = false
        netProc.running = true
    }

    Process {
        id: netProc
        command: ["bash", "-c",
            "nmcli -t -f TYPE,STATE dev | grep ':connected' | head -1 | cut -d: -f1"
        ]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                const t = line.trim().toLowerCase()
                if (t === "wifi" || t === "802-11-wireless") root.netType = "wifi"
                else if (t.includes("ethernet") || t === "802-3-ethernet") root.netType = "ethernet"
                else root.netType = "disconnected"
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: root.refreshNetwork()
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 24
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.05)
            visible: netMouse.containsMouse
        }

        Text {
            anchors.centerIn: parent
            text: root.netIcon
            color: "#f9e2af"
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: netMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Quickshell.execDetached(["sh", "-c", "alacritty -e nmtui"])
    }

    scale: netMouse.pressed ? 0.88 : 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }
}
