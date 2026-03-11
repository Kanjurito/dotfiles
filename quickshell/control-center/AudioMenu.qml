import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    width: 280
    height: visible ? col.implicitHeight + 24 : 0
    visible: false
    clip: true

    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    property var sinks: []
    property string defaultSink: ""

    function refresh() {
        root.sinks = []
        sinksProc.running = false
        sinksProc.running = true
        defaultProc.running = false
        defaultProc.running = true
    }

    Process {
        id: defaultProc
        command: ["sh", "-c", "pactl get-default-sink"]
        stdout: SplitParser { onRead: data => root.defaultSink = data.trim() }
    }

    Process {
        id: sinksProc
        command: ["sh", "-c", "pactl list sinks short | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                const name = data.trim()
                if (!name) return
                const arr = root.sinks.slice()
                // Get description
                descProc.target = name
                descProc.running = false
                descProc.running = true
                arr.push({ name: name, desc: name })
                root.sinks = arr
            }
        }
    }

    Process {
        id: descProc
        property string target: ""
        command: ["sh", "-c", "pactl list sinks | grep -A5 'Name: " + target + "' | grep 'Description' | cut -d: -f2- | xargs"]
        stdout: SplitParser {
            onRead: data => {
                const desc = data.trim()
                if (!desc || !descProc.target) return
                const arr = root.sinks.slice()
                const idx = arr.findIndex(s => s.name === descProc.target)
                if (idx >= 0) arr[idx] = { name: arr[idx].name, desc: desc }
                root.sinks = arr
            }
        }
    }

    Process {
        id: setSinkProc
        property string sink: ""
        command: ["sh", "-c", "pactl set-default-sink '" + sink + "'"]
        onRunningChanged: if (!running) { root.defaultSink = sink }
    }

    onVisibleChanged: if (visible) root.refresh()

    Rectangle {
        anchors.fill: parent
        radius: 12; color: "#0d0520"
        border.color: "#2a1a4a"; border.width: 1

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 12; anchors.topMargin: 14
            spacing: 6

            Row {
                width: parent.width; height: 24
                Text {
                    text: "󰕾  Audio Output"
                    font.pixelSize: 12; font.weight: Font.Bold
                    color: "#fab387"; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: parent.width - 140 - 80; height: 1 }
                Rectangle {
                    width: 80; height: 22; radius: 11
                    color: "#0a1020"; border.color: "#fab38740"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "󰒓 Advanced"
                        font.pixelSize: 10; color: "#fab387"
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: pwvuProc.running = true
                        Process { id: pwvuProc; command: ["pwvucontrol"] }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            Repeater {
                model: root.sinks
                Rectangle {
                    width: col.width; height: 48; radius: 8
                    color: modelData.name === root.defaultSink ? "#1a0e20" : sinkArea.containsMouse ? "#0d0520" : "transparent"
                    border.color: modelData.name === root.defaultSink ? "#fab38740" : "transparent"
                    border.width: 1

                    Row {
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        anchors.leftMargin: 10; anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: modelData.name.includes("hdmi") || modelData.name.includes("HDMI") ? "󰡁" :
                                  modelData.name.includes("blue") || modelData.name.includes("Blue") ? "󰋋" :
                                  modelData.name.includes("usb") || modelData.name.includes("USB") ? "󰕺" : "󰓃"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            color: modelData.name === root.defaultSink ? "#fab387" : "#3a2a5a"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 28 - 20 - 20
                            spacing: 2
                            Text {
                                text: modelData.desc
                                font.pixelSize: 11; font.weight: modelData.name === root.defaultSink ? Font.Medium : Font.Normal
                                color: modelData.name === root.defaultSink ? "#e0d0ff" : "#6a5a8a"
                                font.family: "JetBrainsMono Nerd Font"
                                width: parent.width; elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.name === root.defaultSink ? "Active output" : "Click to select"
                                font.pixelSize: 9
                                color: modelData.name === root.defaultSink ? "#fab387" : "#3a2a5a"
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        Text {
                            visible: modelData.name === root.defaultSink
                            text: "󰄬"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14; color: "#fab387"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: sinkArea; anchors.fill: parent
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            setSinkProc.sink = modelData.name
                            setSinkProc.running = false
                            setSinkProc.running = true
                        }
                    }
                }
            }
        }
    }
}
