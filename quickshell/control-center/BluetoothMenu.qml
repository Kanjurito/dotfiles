import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects

Item {
    id: root
    width: 280
    height: visible ? col.implicitHeight + 24 : 0
    visible: false
    clip: true

    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    property var devices: []
    property bool scanning: false

    function refresh() {
        scanListProc.running = false
        scanListProc.running = true
    }

    // Parse bluetoothctl devices
    Process {
        id: scanListProc
        command: ["sh", "-c", "bluetoothctl devices | while read _ mac name; do info=$(bluetoothctl info $mac 2>/dev/null); connected=$(echo \"$info\" | grep -c 'Connected: yes'); paired=$(echo \"$info\" | grep -c 'Paired: yes'); echo \"$mac|$name|$connected|$paired\"; done"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line) return
                const parts = line.split("|")
                if (parts.length < 4) return
                const dev = { mac: parts[0], name: parts[1], connected: parts[2] === "1", paired: parts[3] === "1" }
                const arr = root.devices.slice()
                const idx = arr.findIndex(d => d.mac === dev.mac)
                if (idx >= 0) arr[idx] = dev; else arr.push(dev)
                root.devices = arr
            }
        }
        onRunningChanged: if (!running) root.scanning = false
    }

    Process {
        id: btScanProc
        command: ["sh", "-c", "bluetoothctl scan on & sleep 4 && bluetoothctl scan off"]
        onRunningChanged: if (!running) root.refresh()
    }

    Process {
        id: btConnectProc
        property string mac: ""
        property bool doConnect: true
        command: ["sh", "-c", (doConnect ? "bluetoothctl connect " : "bluetoothctl disconnect ") + mac]
        onRunningChanged: if (!running) Qt.callLater(root.refresh)
    }

    onVisibleChanged: if (visible) { root.devices = []; root.refresh() }

    Rectangle {
        anchors.fill: parent
        radius: 12; color: "#0d0520"
        border.color: "#2a1a4a"; border.width: 1

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 12
            anchors.topMargin: 14
            spacing: 6

            // Header
            Row {
                width: parent.width; height: 24; spacing: 8
                Text {
                    text: "󰂯  Bluetooth"
                    font.pixelSize: 12; font.weight: Font.Bold
                    color: "#89b4fa"; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: parent.width - 160 - 70; height: 1 }
                // Scan button
                Rectangle {
                    width: 70; height: 22; radius: 11
                    color: root.scanning ? "#1a2a40" : "#0a1020"
                    border.color: "#89b4fa40"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Row {
                        anchors.centerIn: parent; spacing: 4
                        Text {
                            text: root.scanning ? "󰑐" : "󰐨"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10; color: "#89b4fa"
                            anchors.verticalCenter: parent.verticalCenter
                            RotationAnimator on rotation {
                                running: root.scanning; from: 0; to: 360
                                duration: 1000; loops: Animation.Infinite
                            }
                        }
                        Text {
                            text: root.scanning ? "Scan..." : "Scan"
                            font.pixelSize: 10; color: "#89b4fa"
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.scanning = true; btScanProc.running = true }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            // Device list
            Repeater {
                model: root.devices
                Rectangle {
                    width: col.width; height: 44; radius: 8
                    color: modelData.connected ? "#0e1a2e" : "transparent"
                    border.color: modelData.connected ? "#89b4fa30" : "transparent"
                    border.width: 1

                    Row {
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        anchors.leftMargin: 8; anchors.rightMargin: 8
                        spacing: 10

                        Text {
                            text: "󰋋"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18; color: modelData.connected ? "#89b4fa" : "#3a2a5a"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 20 - 10 - 32 - 8
                            spacing: 2
                            Text {
                                text: modelData.name
                                font.pixelSize: 11; font.weight: Font.Medium
                                color: modelData.connected ? "#e0d0ff" : "#6a5a8a"
                                font.family: "JetBrainsMono Nerd Font"
                                width: parent.width; elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.connected ? "Connected" : modelData.paired ? "Paired" : "Available"
                                font.pixelSize: 9
                                color: modelData.connected ? "#a6e3a1" : "#3a2a5a"
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        // Connect / Disconnect button
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: btnArea.containsMouse ? "#20ffffff" : "#0a0a12"
                            border.color: modelData.connected ? "#f38ba840" : "#89b4fa40"
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: modelData.connected ? "󰂲" : "󰂱"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                color: modelData.connected ? "#f38ba8" : "#89b4fa"
                            }
                            MouseArea {
                                id: btnArea; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    btConnectProc.mac = modelData.mac
                                    btConnectProc.doConnect = !modelData.connected
                                    btConnectProc.running = false
                                    btConnectProc.running = true
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            Text {
                visible: root.devices.length === 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.scanning ? "Scanning..." : "No devices found"
                font.pixelSize: 10; color: "#3a2a5a"
                font.family: "JetBrainsMono Nerd Font"
                height: 30; verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
