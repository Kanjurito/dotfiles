import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: 46

    property int percent: 100

    property var battIcons: [
        "󰂎","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"
    ]

    property string battIcon: {
        const idx = Math.min(Math.floor(percent / 10), 10)
        return battIcons[idx]
    }

    function refreshBattery() {
        battProc.running = false
        battProc.running = true
    }

    Process {
        id: battProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 100"
        ]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                const val = parseInt(line.trim())
                if (!isNaN(val)) root.percent = val
            }
        }
    }

    Timer {
        interval: 30000; running: true; repeat: true
        onTriggered: root.refreshBattery()
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
            visible: battMouse.containsMouse
        }

        Text {
            anchors.centerIn: parent
            text: root.battIcon
            color: root.percent <= 20 ? "#f38ba8" : "#a6e3a1"
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    ToolTip {
        visible: battMouse.containsMouse
        text: root.percent + "%"
    }

    MouseArea {
        id: battMouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
