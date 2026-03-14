import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Backlight
Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: 46

    property int brightness: 50  // 0–100

    property string brightIcon: {
        if (brightness < 33) return "󰃞"
        if (brightness < 66) return "󰃟"
        return "󰃠"
    }

    function refreshBrightness() {
        brightnessProc.running = false
        brightnessProc.running = true
    }

    Process {
        id: brightnessProc
        command: ["bash", "-c", "ddcutil getvcp 10 --bus 3 | grep -oP 'current value =\\s*\\K[0-9]+'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                const val = parseInt(line.trim())
                if (!isNaN(val)) root.brightness = val
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refreshBrightness()
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
            visible: brightMouse.containsMouse
        }

        Text {
            anchors.centerIn: parent
            text: root.brightIcon
            color: "#f9e2af"
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: brightMouse
        anchors.fill: parent
        hoverEnabled: true

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                Quickshell.execDetached(["sh", "-c", "bash ~/.config/niri/script/brightness.sh up"])
            } else {
                Quickshell.execDetached(["sh", "-c", "bash ~/.config/niri/script/brightness.sh down"])
            }
            brightnessTimer.restart()
        }
    }

    Timer {
        id: brightnessTimer
        interval: 300
        onTriggered: root.refreshBrightness()
    }

    scale: brightMouse.pressed ? 0.88 : 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }
}
