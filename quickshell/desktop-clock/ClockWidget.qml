import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Effects

PanelWindow {
    id: root

    required property var screen
    WlrLayershell.layer: WlrLayer.Bottom


    // Center on screen
    anchors { left: false; top: false }
    margins {
        left: (root.screen.width  - 260) / 2
        top:  (root.screen.height - 160) / 2
    }

    implicitWidth:  260
    implicitHeight: card.height

    color: "transparent"

    // ---- Data ----
    property string ramStr: "..."
    property int    cpuPct: 0

    SystemClock { id: clock; precision: SystemClock.Seconds }

    function refreshStats() {
        ramCmd.running = false; ramCmd.running = true
        cpuCmd.running = false; cpuCmd.running = true
    }

    Process {
        id: ramCmd
        command: ["sh", "-c", "free | awk '/Mem:/{printf \"%.1f / %.1f GB\", $3/1024/1024, $2/1024/1024}'"]
        stdout: SplitParser { onRead: data => root.ramStr = data.trim() }
    }

    Process {
        id: cpuCmd
        property real firstIdle:  0
        property real firstTotal: 0
        property bool gotFirst:   false
        onRunningChanged: if (running) gotFirst = false
        command: ["sh", "-c",
            "awk '/^cpu /{print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat; sleep 0.5; " +
            "awk '/^cpu /{print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat"
        ]
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(" ")
                if (p.length < 2) return
                var idle = parseFloat(p[0]), total = parseFloat(p[1])
                if (!cpuCmd.gotFirst) {
                    cpuCmd.firstIdle = idle; cpuCmd.firstTotal = total
                    cpuCmd.gotFirst = true
                } else {
                    var di = idle - cpuCmd.firstIdle, dt = total - cpuCmd.firstTotal
                    root.cpuPct = dt > 0 ? Math.round((1 - di / dt) * 100) : 0
                }
            }
        }
    }

    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refreshStats() }

    function cpuColor(p) {
        return p >= 80 ? "#f38ba8" : p >= 50 ? "#fab387" : "#89b4fa"
    }

Rectangle {
    id: card
    anchors.centerIn: parent
    width: 300
    height: col.implicitHeight + 40
    radius: 0
    color: "transparent"
    border.width: 0

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        spacing: 6

        // Heure
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clock.hours.toString().padStart(2,"0") + ":" +
                  clock.minutes.toString().padStart(2,"0") + ":" +
                  clock.seconds.toString().padStart(2,"0")
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 52
            font.weight: Font.Bold
            color: "#cdd6f4"        // text
        }

        // Date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(new Date(), "dddd d MMMM yyyy")
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color: "#a6adc8"        // subtext0
            topPadding: 2
            bottomPadding: 10
        }

        // Ligne subtile
        Rectangle {
            width: 220
            height: 1
            color: "#40cdd6f4"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Infos système
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 12
            spacing: 10
            width: 220

            // RAM
            Row {
                spacing: 8
                width: parent.width
                height: 18

                Text {
                    text: "󰍛"   // icône RAM
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: "#b4befe"   // lavender
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "RAM"
                    font.pixelSize: 12
                    color: "#cdd6f4"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                }

                Text {
                    text: root.ramStr
                    font.pixelSize: 12
                    color: "#a6e3a1"   // green catppuccin
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // CPU
            Row {
                spacing: 8
                width: parent.width
                height: 18

                Text {
                    text: ""   // icône CPU
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: "#cba6f7"   // mauve
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "CPU"
                    font.pixelSize: 12
                    color: "#cdd6f4"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                }

                Item {
                    width: 110
                    height: 6
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 3
                        color: "#1e1e2e"   // surface0
                    }

                    Rectangle {
                        width: parent.width * (root.cpuPct / 100)
                        height: parent.height
                        radius: 3
                        color: root.cpuColor(root.cpuPct)
                        Behavior on width {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    text: root.cpuPct + "%"
                    font.pixelSize: 12
                    color: root.cpuColor(root.cpuPct)
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 4
                }
            }
        }
    }
}

}
