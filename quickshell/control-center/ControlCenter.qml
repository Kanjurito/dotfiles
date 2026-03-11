import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    anchors { left: true; top: true }
    margins { right: 84; top: 10 }

    implicitWidth: 300
    implicitHeight: col.implicitHeight + btMenu.height + wifiMenu.height + audioMenu.height + 36
    visible: false
    color: "transparent"

    // --- State ---
    property real volume: 0.37
    property real brightness: 0.45
    property bool dnd: false
    property bool bluetooth: true
    property bool wifi: true
    property string wifiName: "..."
    property string cpuUsage: "0"
    property string ramUsage: "0"
    property string diskUsage: "0"
    property MprisPlayer activePlayer: null
    Connections {
        target: Mpris.players
        function onObjectInsertedPost() { root.pickPlayer() }
        function onObjectRemovedPost() { root.pickPlayer() }
    }

    Component.onCompleted: { Qt.callLater(pickPlayer); Qt.callLater(refresh) }

    function pickPlayer() {
        const vals = Mpris.players.values
        if (typeof vals !== "object") { activePlayer = null; return }
        let best = null
        for (let i = 0; i < vals.length; i++) {
            const p = vals[i]
            if (p.playbackState === MprisPlaybackState.Playing) { best = p; break }
            if (!best) best = p
        }
        activePlayer = best
    }

    function refresh() {
        volumeProc.running = false;   volumeProc.running = true
        brightProc.running = false;   brightProc.running = true
        wifiProc.running = false;     wifiProc.running = true
        statsProc.running = false;    statsProc.running = true
    }

    onVisibleChanged: if (visible) refresh()
    Timer { interval: 5000; running: root.visible; repeat: true; onTriggered: root.refresh() }

    // Volume
    Process {
        id: volumeProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%'"]
        stdout: SplitParser { onRead: data => { const v = parseInt(data.trim()); if (!isNaN(v)) root.volume = v / 100 } }
    }
    // Brightness via ddcutil i2c
    Process {
        id: brightProc
        command: ["sh", "-c", "ddcutil getvcp 10 --brief --bus 1 2>/dev/null | awk '{print $4}'"]
        stdout: SplitParser { onRead: data => { const v = parseInt(data.trim()); if (!isNaN(v) && v >= 0 && v <= 100) root.brightness = v / 100 } }
    }
    // Wifi name
    Process {
        id: wifiProc
        command: ["sh", "-c", "iwgetid -r 2>/dev/null || echo 'Not connected'"]
        stdout: SplitParser { onRead: data => root.wifiName = data.trim() }
    }
    // CPU / RAM / Disk
    Process {
        id: statsProc
        command: ["sh", "-c", "echo \"cpu:$(top -bn1 | awk '/Cpu/{print int($2+$4)}')\" && echo \"ram:$(free | awk '/Mem/{printf \"%.0f\", $3/$2*100}')\" && echo \"disk:$(df / | awk 'NR==2{print $5}' | tr -d '%')\""]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line.startsWith("cpu:")) root.cpuUsage = line.slice(4)
                else if (line.startsWith("ram:")) root.ramUsage = line.slice(4)
                else if (line.startsWith("disk:")) root.diskUsage = line.slice(5)
            }
        }
    }
    // Volume set
    Process {
        id: setVolumeProc
        property real target: 0
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + Math.round(target * 100) + "%"]
    }
    // Brightness set via ddcutil
    Process {
        id: setBrightProc
        property real target: 0
        command: ["sh", "-c", "for b in 0 1 3; do ddcutil setvcp 10 " + Math.round(target * 100) + " --bus $b 2>/dev/null; done"]
    }
    // Screenshot via niri (interactive area)
    Process { id: screenshotProc; command: ["sh", "-c", "niri msg action screenshot-window 2>/dev/null || (slurp | grim -g - ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png) 2>/dev/null"] }
    // Bluetooth toggle
    Process {
        id: btProc
        command: ["sh", "-c", root.bluetooth ? "bluetoothctl power off" : "bluetoothctl power on"]
        onExited: root.bluetooth = !root.bluetooth
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16; color: "#0a0a12"
        border.color: "#2a1a4a"; border.width: 1
        clip: true

        opacity: root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Rectangle {
            x: -20; y: -20; width: 200; height: 200; radius: 100; color: "#08041a"
            layer.enabled: true
            layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 60 }
        }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 16
            anchors.topMargin: 18
            spacing: 14

            // === CLOCK + ACTIONS ===
            Row {
                width: parent.width; height: 40

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: clock.hours.toString().padStart(2,"0") + ":" + clock.minutes.toString().padStart(2,"0")
                        font.pixelSize: 26; font.weight: Font.Bold
                        color: "#e0d0ff"; font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: Qt.formatDate(new Date(), "dddd d MMMM")
                        font.pixelSize: 10; color: "#4a3a6a"
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Item { width: parent.width - 200 - 80; height: 1 }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    // Settings
                    ActionBtn { icon: "󰕾"; onClicked: {
                            audioMenu.visible = !audioMenu.visible
                            btMenu.visible = false
                            wifiMenu.visible = false
                        }
                    }
                    // Notification center
                    ActionBtn { icon: "󰂚"; onClicked: swayncProc.running = true
                        Process { id: swayncProc; command: ["swaync-client", "-t", "-sw"] }
                    }
                    // Power
                    ActionBtn { icon: ""; accent: "#f38ba8"
                        onClicked: powerProc.running = true
                        Process { id: powerProc; command: ["eww", "-c", "/home/alterra/.config/eww/powermenu/", "open", "--toggle", "powermenu"] }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === TOGGLES GRID ===
            Grid {
                width: parent.width
                columns: 2
                rowSpacing: 8; columnSpacing: 8

                // WiFi
                ToggleCard {
                    width: (parent.width - 8) / 2
                    icon: "󰤨"; label: "Wi-Fi"
                    sublabel: root.wifiName
                    active: root.wifi
                    hasMenu: true
                    onToggled: {
                        wifiMenu.visible = !wifiMenu.visible
                        btMenu.visible = false
                        audioMenu.visible = false
                    }
                }
                // Bluetooth
                ToggleCard {
                    width: (parent.width - 8) / 2
                    icon: "󰂯"; label: "Bluetooth"
                    sublabel: root.bluetooth ? "On" : "Off"
                    active: root.bluetooth
                    hasMenu: true
                    onToggled: {
                        btMenu.visible = !btMenu.visible
                        wifiMenu.visible = false
                        audioMenu.visible = false
                    }
                }
                // Do Not Disturb
                ToggleCard {
                    width: (parent.width - 8) / 2
                    icon: root.dnd ? "󰂛" : "󰂚"; label: "Not Disturb"
                    sublabel: root.dnd ? "On" : "Off"
                    active: root.dnd
                    onToggled: {
                        root.dnd = !root.dnd
                        dndProc.running = true
                    }
                    Process {
                        id: dndProc
                        command: ["swaync-client", root.dnd ? "-dn" : "-df"]
                    }
                }
                // Screenshot
                ToggleCard {
                    width: (parent.width - 8) / 2
                    icon: "󰹑"; label: "Screenshot"
                    sublabel: "Capture area"
                    active: false
                    onToggled: { screenshotProc.running = true; root.visible = false }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === SLIDERS ===
            Column { spacing: 10; width: parent.width

                SliderRow {
                    width: parent.width
                    icon: root.volume > 0.5 ? "󰕾" : root.volume > 0 ? "󰖀" : "󰝟"
                    value: root.volume
                    accentColor: "#cba6f7"
                    onMoved: val => {
                        root.volume = val
                        setVolumeProc.target = val
                        setVolumeProc.running = false
                        setVolumeProc.running = true
                    }
                }
                SliderRow {
                    width: parent.width
                    icon: "󰃞"
                    value: root.brightness
                    accentColor: "#f9e2af"
                    onMoved: val => {
                        root.brightness = val
                        setBrightProc.target = val
                        setBrightProc.running = false
                        setBrightProc.running = true
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // === STATS ===
            Row {
                width: parent.width; spacing: 0

                StatChip {
                    width: parent.width / 3
                    icon: "󰻠"; label: "CPU"
                    value: root.cpuUsage + "%"
                    color: parseInt(root.cpuUsage) > 80 ? "#f38ba8" : "#89b4fa"
                }
                StatChip {
                    width: parent.width / 3
                    icon: "󰍛"; label: "RAM"
                    value: root.ramUsage + "%"
                    color: parseInt(root.ramUsage) > 80 ? "#f38ba8" : "#cba6f7"
                }
                StatChip {
                    width: parent.width / 3
                    icon: "󰋊"; label: "Disk"
                    value: root.diskUsage + "%"
                    color: parseInt(root.diskUsage) > 80 ? "#f38ba8" : "#a6e3a1"
                }
            }

            // === MEDIA PLAYER ===
            Rectangle {
                width: parent.width; height: 64
                radius: 10; color: "#0d0520"
                border.color: "#2a1a4a"; border.width: 1
                visible: root.activePlayer !== null
                clip: true

                // Artwork bg blur
                Image {
                    anchors.fill: parent
                    source: root.activePlayer ? root.activePlayer.trackArtUrl ?? "" : ""
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0.15
                    layer.enabled: true
                    layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 32 }
                }

                Row {
                    anchors.fill: parent; anchors.margins: 8; spacing: 10

                    // Artwork
                    Rectangle {
                        width: 48; height: 48; radius: 6
                        color: "#1a0a30"
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            anchors.fill: parent; anchors.margins: 1
                            source: root.activePlayer ? root.activePlayer.trackArtUrl ?? "" : ""
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: ShaderEffectSource {
                                    sourceItem: Rectangle { width: 46; height: 46; radius: 5 }
                                }
                            }
                        }
                    }

                    // Title + artist
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 48 - 10 - 90 - 10
                        spacing: 3
                        Text {
                            text: root.activePlayer ? root.activePlayer.trackTitle ?? "—" : "—"
                            font.pixelSize: 11; font.weight: Font.Medium
                            color: "#e0d0ff"; font.family: "JetBrainsMono Nerd Font"
                            width: parent.width; elide: Text.ElideRight
                        }
                        Text {
                            text: root.activePlayer ? root.activePlayer.trackArtist ?? "" : ""
                            font.pixelSize: 9; color: "#cba6f7"
                            font.family: "JetBrainsMono Nerd Font"
                            width: parent.width; elide: Text.ElideRight
                        }
                    }

                    // Controls
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Repeater {
                            model: [
                                { icon: "󰒮", action: "prev" },
                                { icon: (root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊", action: "play" },
                                { icon: "󰒭", action: "next" }
                            ]
                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: area.containsMouse ? "#20ffffff" : "transparent"
                                Behavior on color { ColorAnimation { duration: 80 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: modelData.action === "play" ? 15 : 12
                                    color: "#e0d0ff"
                                }
                                MouseArea {
                                    id: area; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!root.activePlayer) return
                                        if (modelData.action === "prev") root.activePlayer.previous()
                                        else if (modelData.action === "play") root.activePlayer.togglePlaying()
                                        else root.activePlayer.next()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // === SUBMENUS ===
        BluetoothMenu {
            id: btMenu
            anchors { left: parent.left; right: parent.right; top: col.bottom }
            anchors.topMargin: 8; anchors.leftMargin: 16; anchors.rightMargin: 16
        }

        WifiMenu {
            id: wifiMenu
            anchors { left: parent.left; right: parent.right; top: btMenu.bottom }
            anchors.topMargin: btMenu.visible ? 8 : 0; anchors.leftMargin: 16; anchors.rightMargin: 16
        }

        AudioMenu {
            id: audioMenu
            anchors { left: parent.left; right: parent.right; top: wifiMenu.bottom }
            anchors.topMargin: wifiMenu.visible ? 8 : 0; anchors.leftMargin: 16; anchors.rightMargin: 16
        }
    }
}
