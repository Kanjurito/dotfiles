import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    required property MprisPlayer player
    signal playerSwitch(int index)

    anchors { left: true; top: true }
    margins { left: 74; top: 10 }

    implicitWidth: 420
    implicitHeight: 200
    visible: false
    color: "transparent"

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 14
        color: "#0a0a12"
        clip: true

        opacity: root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#2a1a4a"
            border.width: 1
            z: 20
        }

        Rectangle {
            x: -20; y: -20
            width: 160; height: 160
            radius: 80
            color: "#15083a"
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true; blur: 1.0; blurMax: 40
            }
        }

        // =====================
        // ARTWORK
        // =====================
        Rectangle {
            id: artBox
            x: 14; y: 14
            width: 118; height: 118
            radius: 10
            color: "#13131f"
            border.color: "#cba6f720"
            border.width: 1

            // Glow artwork
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80cba6f7"
                shadowBlur: 0.5
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
            }

            Text {
                anchors.centerIn: parent; text: "󰎆"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 40; color: "#2a1a4a"
                visible: artImage.status !== Image.Ready
            }

            Image {
                id: artImage
                anchors.fill: parent; anchors.margins: 1
                source: root.player ? root.player.trackArtUrl ?? "" : ""
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: artImage.width; height: artImage.height; radius: 9
                        }
                    }
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: 9
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#20ffffff" }
                    GradientStop { position: 0.4; color: "#00ffffff" }
                }
                z: 5
            }
        }

        // =====================
        // Right
        // =====================
        Column {
            anchors.left: artBox.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.top: parent.top
            anchors.topMargin: 14
            spacing: 4

            // Badge player + volume
            Row {
                width: parent.width
                height: 16

                Rectangle {
                    height: 16; width: badgeText.implicitWidth + 10
                    radius: 8; color: "#1a0a30"
                    border.color: "#cba6f730"; border.width: 1
                    Text {
                        id: badgeText
                        anchors.centerIn: parent
                        text: root.player ? root.player.identity ?? "—" : "—"
                        font.pixelSize: 9; color: "#cba6f7"
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: 1
                    }
                }

                Item { width: parent.width - badgeText.implicitWidth - 10 - volIcon.implicitWidth - 4; height: 1 }

                // Volume icon
                Text {
                    id: volIcon
                    anchors.verticalCenter: parent.verticalCenter
                    text: (root.player && root.player.volume > 0.5) ? "󰕾" :
                          (root.player && root.player.volume > 0) ? "󰖀" : "󰝟"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13; color: "#cba6f7"
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -4
                        onClicked: if (root.player)
                            root.player.volume = root.player.volume > 0 ? 0 : 0.7
                    }
                }
            }

            // Title
            Item {
                width: parent.width; height: 20; clip: true
                Text {
                    id: titleText
                    text: root.player ? root.player.trackTitle ?? "No track" : "No track"
                    font.pixelSize: 14; font.weight: Font.Bold
                    color: "#e0d0ff"
                    font.family: "JetBrainsMono Nerd Font"
                    x: 0
                }
                NumberAnimation {
                    target: titleText; property: "x"
                    from: 4; to: -(titleText.implicitWidth - parent.width + 8)
                    duration: Math.max(3000, (titleText.implicitWidth - parent.width) * 25)
                    loops: Animation.Infinite
                    running: titleText.implicitWidth > parent.width
                }
            }

            Text {
                text: root.player ? root.player.trackArtist ?? "" : ""
                font.pixelSize: 11; color: "#cba6f7"
                font.family: "JetBrainsMono Nerd Font"
                width: parent.width; elide: Text.ElideRight
            }

            Item {
                width: parent.width; height: 18

                Text {
                    id: posText
                    anchors.left: parent.left; anchors.verticalCenter: progressBar.verticalCenter
                    text: formatTime(root.player ? root.player.position : 0)
                    font.pixelSize: 8; color: "#6a5a8a"
                    font.family: "JetBrainsMono Nerd Font"
                }

                Rectangle {
                    id: progressBar
                    anchors.left: posText.right; anchors.leftMargin: 5
                    anchors.right: durText.left; anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    height: 3; radius: 2; color: "#1a1030"

                    Rectangle {
                        property real len: (root.player && root.player.trackLength != null) ? root.player.trackLength : 0
                        property real pos: (root.player && root.player.position != null) ? root.player.position : 0
                        width: len > 0 ? parent.width * Math.min(1, pos / len) : 0
                        height: parent.height; radius: 2
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#89b4fa" }
                            GradientStop { position: 1.0; color: "#cba6f7" }
                        }
                        Behavior on width { NumberAnimation { duration: 500 } }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 7; height: 7; radius: 4
                            color: "#cba6f7"
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true; shadowColor: "#aacba6f7"
                                shadowBlur: 0.9
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; anchors.margins: -6
                        onClicked: function(mouse) {
                            if (!root.player) return
                            const ratio = Math.max(0, Math.min(1, (mouse.x + 6) / (width)))
                            root.player.position = ratio * root.player.trackLength
                        }
                    }
                }

                Text {
                    id: durText
                    anchors.right: parent.right; anchors.verticalCenter: progressBar.verticalCenter
                    text: formatTime(root.player ? root.player.trackLength : 0)
                    font.pixelSize: 8; color: "#6a5a8a"
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Contrôles
            Row {
                width: parent.width
                height: 32
                spacing: 0

                // Shuffle
                NeonButton {
                    width: 28; height: 32; icon: "󰒝"; iconSize: 12
                    active: root.player ? root.player.shuffle ?? false : false
                    activeColor: "#cba6f7"
                    onClicked: { if (root.player) root.player.shuffle = !root.player.shuffle }
                }

                Item { width: parent.width - 28*2 - 36 - 28; height: 1 }

                NeonButton {
                    width: 28; height: 32; icon: "󰒮"; iconSize: 14
                    onClicked: { if (root.player) root.player.previous() }
                }
                NeonButton {
                    width: 36; height: 32
                    icon: (root.player && root.player.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                    iconSize: 18; activeColor: "#cba6f7"; active: true; glowing: true
                    onClicked: { if (root.player) root.player.togglePlaying() }
                }
                NeonButton {
                    width: 28; height: 32; icon: "󰒭"; iconSize: 14
                    onClicked: { if (root.player) root.player.next() }
                }

                Item { width: 4; height: 1 }

                // Loop
                NeonButton {
                    width: 28; height: 32
                    property int ls: root.player ? root.player.loopState : 0
                    icon: ls === 1 ? "󰑘" : (ls === 2 ? "󰑖" : "󰑗")
                    iconSize: 12; active: ls !== 0; activeColor: "#89b4fa"
                    onClicked: { if (root.player) root.player.loopState = (root.player.loopState + 1) % 3 }
                }
            }
        }

        // =====================
        // EQUALIZER
        // =====================
        Item {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.left: artBox.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 14
            height: 26

            Equalizer {
                anchors.fill: parent
                active: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing
                barColor: "#cba6f7"
            }
        }

        // =====================
        // PLAYER SWITCHER
        // =====================
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16
            spacing: 5

            Repeater {
                model: Mpris.players.values ? Mpris.players.values.length : 0
                Rectangle {
                    property var p: Mpris.players.values ? Mpris.players.values[index] : null
                    width: root.player === p ? 14 : 5
                    height: 5; radius: 3
                    color: root.player === p ? "#cba6f7" : "#2a1a4a"
                    Behavior on width { NumberAnimation { duration: 150 } }
                    layer.enabled: root.player === p
                    layer.effect: MultiEffect {
                        shadowEnabled: true; shadowColor: "#aacba6f7"; shadowBlur: 0.8
                    }
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -5
                        onClicked: root.playerSwitch(index)
                    }
                }
            }
        }
    }

    function formatTime(secs) {
        const s = Math.floor((secs != null && !isNaN(secs)) ? secs : 0)
        const m = Math.floor(s / 60)
        const sec = s % 60
        return m + ":" + (sec < 10 ? "0" : "") + sec
    }
}
