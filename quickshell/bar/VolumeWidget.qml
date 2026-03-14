import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: sliderVisible ? 46 + 98 + 8 : 46

    property int volume: 50
    property bool muted: false
    property bool sliderVisible: false
    property bool dragging: false

    property string volIcon: {
        if (muted) return ""
        if (volume < 33) return ""
        return ""
    }

    function refreshVolume() {
        volProc.running = false
        volProc.running = true
    }

    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                const match = line.match(/Volume:\s*([\d.]+)(\s*\[MUTED\])?/)
                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100)
                    root.muted = match[2] !== undefined
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: { if (!root.dragging) root.refreshVolume() }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Item {
            visible: root.sliderVisible
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 46
            implicitHeight: 98

            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"
                radius: 24
                border.color: Qt.rgba(1, 1, 1, 0.1)
                border.width: 1

                // Track
                Rectangle {
                    id: track
                    anchors.centerIn: parent
                    width: 8
                    height: 70
                    radius: 4
                    color: "#313244"

                    // Fill
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * (root.volume / 100)
                        radius: 4
                        color: "#fab387"
                    }

                    // Handle
                    Rectangle {
                        x: (parent.width - width) / 2
                        y: parent.height * (1 - root.volume / 100) - height / 2
                        width: 14; height: 14
                        radius: 7
                        color: "#fab387"
                    }

                    MouseArea {
                        anchors.fill: parent
                        preventStealing: true

                        function setVolumeFromY(mouseY) {
                            const clamped = Math.max(0, Math.min(track.height, mouseY))
                            const vol = Math.round((1 - clamped / track.height) * 100)
                            root.volume = vol
                            Quickshell.execDetached(["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + vol + "%"])
                        }

                        onPressed: (mouse) => {
                            root.dragging = true
                            setVolumeFromY(mouse.y)
                        }
                        onPositionChanged: (mouse) => {
                            if (pressed) setVolumeFromY(mouse.y)
                        }
                        onReleased: {
                            root.dragging = false
                            root.refreshVolume()
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 46; implicitHeight: 46
            color: "#1e1e2e"
            radius: 24
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: Qt.rgba(1, 1, 1, 0.05)
                visible: btnMouse.containsMouse
            }

            Text {
                anchors.centerIn: parent
                text: root.volIcon
                color: "#fab387"
                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                id: btnMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.sliderVisible = !root.sliderVisible
                onWheel: (wheel) => {
                    const delta = wheel.angleDelta.y > 0 ? "5%" : "5%-"
                    Quickshell.execDetached(["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + delta])
                    Qt.callLater(root.refreshVolume)
                }
            }
        }
    }
}
