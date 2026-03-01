import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    anchors { left: true; bottom: true }
    margins { left: 74; bottom: 10 }

    implicitWidth: 320
    implicitHeight: 480
    visible: false
    color: "transparent"

    // --- State ---
    property string localIp: "..."
    property string pingResult: "..."
    property int lanDevices: 0
    property string netDown: "..."
    property string netUp: "..."
    property string nasDisk1: "..."
    property string nasDisk2: "..."
    property bool nasLoading: false

    function refresh() {
        ipProc.running = false;        ipProc.running = true
        pingProc.running = false;      pingProc.running = true
        lanProc.running = false;       lanProc.running = true
        netProc.running = false;       netProc.running = true
        nasProc.running = false;       nasProc.running = true
    }

    onVisibleChanged: if (visible) refresh()
    Timer { interval: 10000; running: root.visible; repeat: true; onTriggered: root.refresh() }

    // Local IP
    Process {
        id: ipProc
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}'"]
        stdout: SplitParser { onRead: data => root.localIp = data.trim() || "N/A" }
    }

    // Ping to Debian server
    Process {
        id: pingProc
        command: ["sh", "-c", "ping -c1 -W2 192.168.1.81 2>/dev/null | awk -F'/' 'END{print $5\"ms\"}' || echo 'timeout'"]
        stdout: SplitParser { onRead: data => root.pingResult = data.trim() }
    }

    // LAN device count
    Process {
        id: lanProc
        command: ["sh", "-c", "ip neigh show | grep -c 'REACHABLE\\|STALE\\|DELAY' 2>/dev/null || echo 0"]
        stdout: SplitParser { onRead: data => root.lanDevices = parseInt(data.trim()) || 0 }
    }

    // Network usage (rx/tx over 1s sample)
    Process {
        id: netProc
        command: ["/home/alterra/dotfiles/quickshell/network-dashboard/netspeed.sh"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length === 2) {
                    root.netDown = formatBytes(parseInt(parts[0]))
                    root.netUp   = formatBytes(parseInt(parts[1]))
                }
            }
        }
    }

    // NAS disk usage via SSH
    Process {
        id: nasProc
        command: ["/home/alterra/dotfiles/quickshell/network-dashboard/nasdisks.sh"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line === "unreachable" || line === "") {
                    root.nasDisk1 = "unreachable"; root.nasDisk2 = ""
                    return
                }
                // Format: used|size|percent
                const parts = line.split("|")
                if (parts.length >= 3) {
                    if (root.nasDisk1 === "...") root.nasDisk1 = parts[0] + " / " + parts[1] + " (" + parts[2] + ")"
                    else root.nasDisk2 = parts[0] + " / " + parts[1] + " (" + parts[2] + ")"
                }
            }
        }
    }

    function formatBytes(kb) {
        if (kb < 1024) return kb + " KB/s"
        return (kb / 1024).toFixed(1) + " MB/s"
    }

    SystemClock { id: clock; precision: SystemClock.Seconds }

    // --- UI ---
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16; color: "#0a0a12"
        border.color: "#2a1a4a"; border.width: 1
        clip: true

        opacity: root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        // Background glow
        Rectangle {
            x: -20; y: -20; width: 180; height: 180; radius: 90
            color: "#0a0520"
            layer.enabled: true
            layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 60 }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // === HEADER ===
            Row {
                width: parent.width; height: 24; spacing: 8

                Text {
                    text: "󰈀"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16; color: "#89b4fa"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Network Dashboard"
                    font.pixelSize: 13; font.weight: Font.Bold
                    color: "#e0d0ff"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: 1; height: 1 }
                Text {
                    
                    text: clock.hours.toString().padStart(2,"0") + ":" + clock.minutes.toString().padStart(2,"0") + ":" + clock.seconds.toString().padStart(2,"0")
                    font.pixelSize: 10; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === LOCAL INFO ===
            Column { spacing: 8; width: parent.width

                StatRow { width: parent.width; icon: "󰩟"; label: "Local IP"; value: root.localIp; valueColor: "#89b4fa" }
                StatRow { width: parent.width; icon: "󱦂"; label: "LAN devices"; value: root.lanDevices + " hosts"; valueColor: "#cba6f7" }
                StatRow {
                    width: parent.width; icon: "󰓅"; label: "Ping (server)"
                    value: root.pingResult
                    valueColor: {
                        if (root.pingResult === "timeout") return "#f38ba8"
                        const ms = parseFloat(root.pingResult)
                        if (ms < 5) return "#a6e3a1"
                        if (ms < 20) return "#f9e2af"
                        return "#fab387"
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === BANDWIDTH ===
            Column { spacing: 8; width: parent.width

                Text {
                    text: "Bandwidth"
                    font.pixelSize: 10; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 1
                }
                StatRow { width: parent.width; icon: "󰁅"; label: "Download"; value: root.netDown; valueColor: "#a6e3a1" }
                StatRow { width: parent.width; icon: "󰁝"; label: "Upload"; value: root.netUp; valueColor: "#fab387" }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === SSH BUTTONS ===
            Column { spacing: 8; width: parent.width

                Text {
                    text: "Quick Connect"
                    font.pixelSize: 10; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 1
                }

                // Debian server
                SshButton {
                    width: parent.width
                    label: "Debian Server"
                    host: "alterra@192.168.1.81"
                    icon: ""
                    color: "#89b4fa"
                }

                // NAS
                SshButton {
                    width: parent.width
                    label: "NAS"
                    host: "root@192.168.1.27"
                    icon: "󱛟"
                    color: "#cba6f7"
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === NAS DISKS ===
            Column { spacing: 8; width: parent.width

                Text {
                    text: "NAS Storage"
                    font.pixelSize: 10; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 1
                }
                StatRow { width: parent.width; icon: "󰋊"; label: "Disk 1"; value: root.nasDisk1; valueColor: "#f9e2af" }
                StatRow {
                    width: parent.width; icon: "󰋊"; label: "Disk 2"
                    value: root.nasDisk2 !== "" ? root.nasDisk2 : "—"
                    valueColor: "#f9e2af"
                    visible: root.nasDisk1 !== "unreachable"
                }
            }
        }
    }
}
