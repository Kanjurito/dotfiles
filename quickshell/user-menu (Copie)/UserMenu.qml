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

    function refreshStats() {
        uptimeCmd.running = false; uptimeCmd.running = true
        procCmd.running = false; procCmd.running = true
        ramCmd.running = false; ramCmd.running = true
    }

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

    onVisibleChanged: if (visible) refreshStats()
    Timer { interval: 5000; running: root.visible; repeat: true; onTriggered: root.refreshStats() }

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

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16; color: "#0a0a12"
        border.color: "#2a1a4a"; border.width: 1
        clip: true

        // Total height adapts to banner size
        property real neededHeight: bannerItem.y + bannerItem.height + 18 + 3*16 + 2*12 + 20

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

                    // Fallback icon if no picture found
                    Text {
                        anchors.centerIn: parent; text: "󰀄"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 30; color: "#cba6f7"
                        visible: avatarImg.status !== Image.Ready
                    }
                }

                // Avatar glow
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true; shadowColor: "#80cba6f7"
                    shadowBlur: 0.6; shadowHorizontalOffset: 0; shadowVerticalOffset: 0
                }

                // Click to change avatar
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

        // Separator follows clock column directly
        Rectangle {
            x: 20; y: clockCol.y + clockCol.height + 8
            width: parent.width - 40; height: 1; color: "#1a0a30"
        }

        // =====================
        // BANNER IMAGE
        // Place your banner at:
        // ~/.config/quickshell/user-menu/img/banner.jpg
        // Aspect ratio is preserved automatically regardless of image resolution
        // =====================
        Item {
            id: bannerItem
            x: 20; y: clockCol.y + clockCol.height + 18
            width: parent.width - 40
            // Height adapts to image aspect ratio, capped between 60 and 120px
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

            // Subtle dim overlay
            Rectangle {
                anchors.fill: parent; radius: 8
                color: "#30000000"
            }

            // Fallback if no banner found
            Rectangle {
                anchors.fill: parent; radius: 8
                color: "#0d0520"
                visible: bannerImg.status !== Image.Ready
                Text {
                    anchors.centerIn: parent
                    text: "banner.jpg"
                    font.pixelSize: 10; color: "#2a1a4a"
                    font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 2
                }
            }
        }

        Rectangle {
            x: 20
            y: bannerItem.y + bannerItem.height + 8
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
                Text { text: "Uptime"; font.pixelSize: 11; color: "#3a2a5a"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter; width: 74 }
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
                Text { text: "RAM"; font.pixelSize: 11; color: "#3a2a5a"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter; width: 74 }
                Text { text: root.ramStr; font.pixelSize: 11; color: "#a6e3a1"; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
}
