import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    anchors { left: true; bottom: true }
    margins { left: 74; bottom: 10 }

    implicitWidth: 300
    implicitHeight: card.neededHeight
    visible: false
    color: "transparent"

    // --- System stats ---
    property string uptimeStr: "..."
    property string procStr: "..."
    property string ramStr: "..."

    // --- KDE Connect / Phone stats ---
    readonly property string kdeDevId: "5d9f8caaba2a429db029254433844871"
    property int   phoneBattery:    -1
    property bool  phoneCharging:   false
    property bool  phoneConnected:  false
    property string phoneNetwork:   ""   // "0".."4" bars or ""
    property string phoneName:      "Smartphone"
    property int   phoneNotifCount: 0

    function refreshStats() {
        uptimeCmd.running   = false; uptimeCmd.running   = true
        procCmd.running     = false; procCmd.running     = true
        ramCmd.running      = false; ramCmd.running      = true
    }

    function refreshPhone() {
        phoneBatCmd.running   = false; phoneBatCmd.running   = true
        phoneNetCmd.running   = false; phoneNetCmd.running   = true
        phoneNameCmd.running = false; phoneNameCmd.running = true
        phoneNotifCmd.running = false; phoneNotifCmd.running = true
        phoneCheckCmd.running = false; phoneCheckCmd.running = true
    }

    // ---- System processes ----
    Process {
        id: uptimeCmd
        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        stdout: SplitParser { onRead: data => root.uptimeStr = data.trim() }
    }
    Process {
        id: procCmd
        command: ["sh", "-c", "echo \"$(ps aux | wc -l) proc\""]
        stdout: SplitParser { onRead: data => root.procStr = data.trim() }
    }
    Process {
        id: ramCmd
        command: ["sh", "-c", "free -h | awk '/Mem:/{print $3 \" / \" $2}'"]
        stdout: SplitParser { onRead: data => root.ramStr = data.trim() }
    }

    // ---- KDE Connect: is device reachable? ----
    Process {
        id: phoneCheckCmd
        command: ["sh", "-c",
            "kdeconnect-cli --device " + root.kdeDevId + " --refresh 2>/dev/null; " +
            "kdeconnect-cli -a --id-only 2>/dev/null | grep -q " + root.kdeDevId + " && echo connected || echo disconnected"
        ]
        stdout: SplitParser {
            onRead: data => root.phoneConnected = (data.trim() === "connected")
        }
    }

    // ---- KDE Connect: battery via D-Bus ----
    // Output: ({'charge': <92>, 'isCharging': <false>},)
    Process {
        id: phoneBatCmd
        command: ["sh", "-c",
            "gdbus call --session --dest org.kde.kdeconnect.daemon " +
            "--object-path /modules/kdeconnect/devices/" + root.kdeDevId + "/battery " +
            "--method org.freedesktop.DBus.Properties.GetAll " +
            "'org.kde.kdeconnect.device.battery' 2>/dev/null"
        ]
        stdout: SplitParser {
            onRead: data => {
                var mc = data.match(/'charge'[^<]*<(\d+)>/)
                if (mc) root.phoneBattery = parseInt(mc[1])
                var mi = data.match(/'isCharging'[^<]*<(true|false)>/)
                if (mi) root.phoneCharging = (mi[1] === "true")
            }
        }
    }

    // ---- KDE Connect: network signal strength via D-Bus ----
    // Output: ({'cellularNetworkStrength': <3>, 'cellularNetworkType': <'Unknown'>},)
    Process {
        id: phoneNetCmd
        command: ["sh", "-c",
            "gdbus call --session --dest org.kde.kdeconnect.daemon " +
            "--object-path /modules/kdeconnect/devices/" + root.kdeDevId + "/connectivity_report " +
            "--method org.freedesktop.DBus.Properties.GetAll " +
            "'org.kde.kdeconnect.device.connectivity_report' 2>/dev/null"
        ]
        stdout: SplitParser {
            onRead: data => {
                var m = data.match(/'cellularNetworkStrength'[^<]*<(\d+)>/)
                root.phoneNetwork = m ? m[1] : ""
            }
        }
    }

    // ---- KDE Connect: phone name via D-Bus ----
    // From: readonly s name = 'Galaxy A05s'
    Process {
        id: phoneNameCmd
        command: ["sh", "-c",
            "gdbus call --session --dest org.kde.kdeconnect.daemon " +
            "--object-path /modules/kdeconnect/devices/" + root.kdeDevId + " " +
            "--method org.freedesktop.DBus.Properties.Get " +
            "'org.kde.kdeconnect.device' 'name' 2>/dev/null"
        ]
        stdout: SplitParser {
            onRead: data => {
                var m = data.match(/<'([^']+)'>/)
                if (m && m[1]) root.phoneName = m[1]
            }
        }
    }

    // ---- KDE Connect: notifications via D-Bus ----
    Process {
        id: phoneNotifCmd
        command: ["sh", "-c",
            "gdbus call --session --dest org.kde.kdeconnect.daemon " +
            "--object-path /modules/kdeconnect/devices/" + root.kdeDevId + "/notifications " +
            "--method org.kde.kdeconnect.device.notifications.activeNotifications 2>/dev/null"
        ]
        stdout: SplitParser {
            onRead: data => {
                // Returns array of notification IDs: (['id1', 'id2'],) or ([],)
                if (data.trim() === "([],)" || data.trim() === "") {
                    root.phoneNotifCount = 0
                } else {
                    var matches = data.match(/'[^']+'/g)
                    root.phoneNotifCount = matches ? matches.length : 0
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            refreshStats()
            refreshPhone()
        }
    }
    Timer { interval: 5000;  running: root.visible; repeat: true; onTriggered: root.refreshStats() }
    Timer { interval: 10000; running: root.visible; repeat: true; onTriggered: root.refreshPhone() }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    // --- Change avatar via file picker ---
    Process {
        id: pickAvatarProc
        command: ["sh", "-c",
            "f=$(zenity --file-selection --title='Choose a picture' --file-filter='Images | *.png *.jpg *.jpeg' 2>/dev/null) && [ -n \"$f\" ] && cp \"$f\" /home/alterra/.config/quickshell/user-menu/img/pp.jpg"]
        onRunningChanged: {
            if (!running) {
                avatarImg.source = ""
                Qt.callLater(function() {
                    avatarImg.source = "file:///home/alterra/.config/quickshell/user-menu/img/pp.jpg?" + Date.now()
                })
            }
        }
    }

    // ---- Helpers ----

    // Battery icon based on level + charging state
    function batIcon(pct, charging) {
        if (pct < 0) return "󰂑"
        if (charging) return "󰂄"
        if (pct >= 90) return "󰁹"
        if (pct >= 70) return "󰂀"
        if (pct >= 50) return "󰁿"
        if (pct >= 30) return "󰁾"
        if (pct >= 15) return "󰁼"
        return "󰁺"
    }

    function batColor(pct, charging) {
        if (charging) return "#a6e3a1"
        if (pct < 0)  return "#4a3a6a"
        if (pct <= 15) return "#f38ba8"
        if (pct <= 35) return "#fab387"
        return "#a6e3a1"
    }

    // Signal bars icon (0-4)
    function netIcon(bars) {
        if (bars === "") return "󰤫"
        var b = parseInt(bars)
        if (b <= 0) return "󰤯"
        if (b === 1) return "󰤟"
        if (b === 2) return "󰤢"
        if (b === 3) return "󰤥"
        return "󰤨"
    }

    function netColor(bars) {
        if (bars === "") return "#4a3a6a"
        var b = parseInt(bars)
        if (b <= 1) return "#f38ba8"
        if (b === 2) return "#fab387"
        return "#89b4fa"
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16; color: "#0a0a12"
        border.color: "#2a1a4a"; border.width: 1
        clip: true

        // Height: header + sep + clock + sep + banner + sep + stats + sep + phone section + bottom margin
        property real statsY:   bannerItem.y + bannerItem.height + 18
        property real statsH:   3 * 16 + 2 * 12          // 3 rows, spacing 12
        property real phoneSepY: statsY + statsH + 14
        property real phoneY:   phoneSepY + 12
        // phone rows: connected indicator + battery + network + notifs + (media when present)
        property real phoneRows: 4
        property real phoneH:   phoneRows * 16 + (phoneRows - 1) * 12
        property real neededHeight: phoneY + phoneH + 22

        opacity: root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        // Background glow
        Rectangle {
            x: -30; y: -30; width: 200; height: 200; radius: 100
            color: "#10052a"
            layer.enabled: true
            layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 60 }
        }

        // =====================
        // HEADER: Avatar + Name
        // =====================
        Row {
            x: 20; y: 20
            width: parent.width - 40
            height: 64
            spacing: 16

            Item {
                width: 64; height: 64

                Rectangle {
                    anchors.fill: parent; radius: 32
                    color: "#1a0a30"
                    border.color: "#cba6f7"; border.width: 2

                    Image {
                        id: avatarImg
                        anchors.fill: parent; anchors.margins: 2
                        source: "file:///home/alterra/.config/quickshell/user-menu/img/pp.jpg"
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: ShaderEffectSource {
                                sourceItem: Rectangle {
                                    width: avatarImg.width; height: avatarImg.height
                                    radius: width / 2
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent; text: "󰀄"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 30; color: "#cba6f7"
                        visible: avatarImg.status !== Image.Ready
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true; shadowColor: "#80cba6f7"
                    shadowBlur: 0.6; shadowHorizontalOffset: 0; shadowVerticalOffset: 0
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: pickAvatarProc.running = true
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Text {
                    text: "kanjurito"
                    font.pixelSize: 20; font.weight: Font.Bold
                    color: "#e0d0ff"
                    font.family: "JetBrainsMono Nerd Font"
                }
                Row {
                    spacing: 5
                    Text {
                        text: "󰉋"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10; color: "#4a3a6a"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "/home/alterra"
                        font.pixelSize: 10; color: "#4a3a6a"
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }

        Rectangle { x: 20; y: 100; width: parent.width - 40; height: 1; color: "#1a0a30" }

        // =====================
        // CLOCK + DATE
        // =====================
        Column {
            id: clockCol
            x: 20; y: 108; spacing: 2

            Text {
                text: clock.hours.toString().padStart(2,"0") + ":" + clock.minutes.toString().padStart(2,"0")
                font.pixelSize: 42; font.weight: Font.Bold
                color: "#e0d0ff"
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                text: Qt.formatDate(new Date(), "dddd d MMMM yyyy")
                font.pixelSize: 11; color: "#4a3a6a"
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Rectangle {
            x: 20; y: clockCol.y + clockCol.height + 8
            width: parent.width - 40; height: 1; color: "#1a0a30"
        }

        // =====================
        // BANNER IMAGE
        // =====================
        Item {
            id: bannerItem
            x: 20; y: clockCol.y + clockCol.height + 18
            width: parent.width - 40
            height: bannerImg.status === Image.Ready
                ? Math.min(120, Math.max(60, width * bannerImg.implicitHeight / Math.max(1, bannerImg.implicitWidth)))
                : 60
            clip: true

            Behavior on height { NumberAnimation { duration: 150 } }

            Image {
                id: bannerImg
                anchors.fill: parent
                source: "file:///home/alterra/.config/quickshell/user-menu/img/banner.jpg"
                fillMode: Image.PreserveAspectCrop
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: bannerImg.width; height: bannerImg.height; radius: 8
                        }
                    }
                }
            }

            Rectangle { anchors.fill: parent; radius: 8; color: "#30000000" }

            Rectangle {
                anchors.fill: parent; radius: 8; color: "#0d0520"
                visible: bannerImg.status !== Image.Ready
                Text {
                    anchors.centerIn: parent; text: "banner.jpg"
                    font.pixelSize: 10; color: "#2a1a4a"
                    font.family: "JetBrainsMono Nerd Font"; font.letterSpacing: 2
                }
            }
        }

        Rectangle {
            x: 20; y: bannerItem.y + bannerItem.height + 8
            width: parent.width - 40; height: 1; color: "#1a0a30"
        }

        // =====================
        // SYSTEM STATS
        // =====================
        Column {
            x: 20; y: bannerItem.y + bannerItem.height + 18
            width: parent.width - 40
            spacing: 12

            Row {
                spacing: 6; height: 16
                Text { text: "󰔟"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; color: "#3a2a5a"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Uptime";    font.pixelSize: 11; color: "#3a2a5a"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter; width: 74 }
                Text { text: root.uptimeStr; font.pixelSize: 11; color: "#cba6f7"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                spacing: 6; height: 16
                Text { text: "󰘚"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; color: "#3a2a5a"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Processes"; font.pixelSize: 11; color: "#3a2a5a"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter; width: 74 }
                Text { text: root.procStr; font.pixelSize: 11; color: "#89b4fa"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                spacing: 6; height: 16
                Text { text: "󰍛"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; color: "#3a2a5a"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "RAM";       font.pixelSize: 11; color: "#3a2a5a"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter; width: 74 }
                Text { text: root.ramStr; font.pixelSize: 11; color: "#a6e3a1"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        // =====================
        // SEPARATOR + PHONE SECTION HEADER
        // =====================
        Rectangle {
            x: 20; y: card.phoneSepY
            width: parent.width - 40; height: 1; color: "#1a0a30"
        }

        // Small "Smartphone" label with phone icon
        Row {
            x: 20; y: card.phoneSepY + 4
            spacing: 5; height: 14

            Text {
                text: root.phoneConnected ? "󰄜" : "󰄝"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                color: root.phoneConnected ? "#cba6f7" : "#3a2a5a"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.phoneName
                font.pixelSize: 9; font.letterSpacing: 1.5
                color: root.phoneConnected ? "#5a4a7a" : "#3a2a5a"
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Disconnected badge
            Rectangle {
                visible: !root.phoneConnected
                anchors.verticalCenter: parent.verticalCenter
                width: offLabel.width + 8; height: 12; radius: 6
                color: "#1a0a20"
                Text {
                    id: offLabel
                    anchors.centerIn: parent
                    text: "offline"
                    font.pixelSize: 8; color: "#f38ba8"
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }

        // =====================
        // PHONE STATS ROWS
        // =====================
        Column {
            x: 20; y: card.phoneY + 4
            width: parent.width - 40
            spacing: 12
            opacity: root.phoneConnected ? 1.0 : 0.35

            // --- Battery ---
            Row {
                spacing: 6; height: 16
                Text {
                    text: root.batIcon(root.phoneBattery, root.phoneCharging)
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                    color: root.batColor(root.phoneBattery, root.phoneCharging)
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Battery"
                    font.pixelSize: 11; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter; width: 74
                }
                Text {
                    text: root.phoneBattery < 0
                        ? "—"
                        : root.phoneBattery + "%" + (root.phoneCharging ? "  ⚡" : "")
                    font.pixelSize: 11
                    color: root.batColor(root.phoneBattery, root.phoneCharging)
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // --- Network signal ---
            Row {
                spacing: 6; height: 16
                Text {
                    text: root.netIcon(root.phoneNetwork)
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                    color: root.netColor(root.phoneNetwork)
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Signal"
                    font.pixelSize: 11; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter; width: 74
                }
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Repeater {
                        model: 4
                        Rectangle {
                            width: 5
                            height: 6 + index * 3
                            anchors.bottom: parent ? parent.bottom : undefined
                            radius: 1
                            color: {
                                var bars = root.phoneNetwork !== "" ? parseInt(root.phoneNetwork) : -1
                                if (bars < 0) return "#2a1a4a"
                                return index < bars ? root.netColor(root.phoneNetwork) : "#2a1a4a"
                            }
                        }
                    }

                    Text {
                        text: root.phoneNetwork !== "" ? " " + root.phoneNetwork + "/4" : " —"
                        font.pixelSize: 11; color: root.netColor(root.phoneNetwork)
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // --- Notifications ---
            Row {
                spacing: 6; height: 16
                Text {
                    text: root.phoneNotifCount > 0 ? "󰂚" : "󰂜"
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                    color: root.phoneNotifCount > 0 ? "#fab387" : "#3a2a5a"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Notifs"
                    font.pixelSize: 11; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter; width: 74
                }
                Text {
                    text: root.phoneNotifCount > 0 ? root.phoneNotifCount + " pending" : "none"
                    font.pixelSize: 11
                    color: root.phoneNotifCount > 0 ? "#fab387" : "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }


        }
    }
}
