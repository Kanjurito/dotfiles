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

    property var networks: []
    property bool scanning: false
    property string connected: ""

    function refresh() {
        root.networks = []
        wifiScanProc.running = false
        wifiScanProc.running = true
    }

    Process {
        id: wifiScanProc
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null | sort -t: -k2 -rn | head -12"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line) return
                const parts = line.split(":")
                if (parts.length < 3) return
                const net = {
                    ssid: parts[0],
                    signal: parseInt(parts[1]) || 0,
                    secure: parts[2] !== "--",
                    active: parts[3] === "*"
                }
                if (net.ssid === "") return
                if (net.active) root.connected = net.ssid
                const arr = root.networks.slice()
                arr.push(net)
                root.networks = arr
            }
        }
        onRunningChanged: root.scanning = running
    }

    Process {
        id: wifiConnectProc
        property string ssid: ""
        command: ["sh", "-c", "nmcli dev wifi connect '" + ssid + "' 2>/dev/null"]
        onRunningChanged: if (!running) Qt.callLater(root.refresh)
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
                width: parent.width; height: 24; spacing: 8
                Text {
                    text: "󰤨  Wi-Fi"
                    font.pixelSize: 12; font.weight: Font.Bold
                    color: "#a6e3a1"; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: parent.width - 120 - 70; height: 1 }
                Rectangle {
                    width: 70; height: 22; radius: 11
                    color: "#0a1020"; border.color: "#a6e3a140"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Row {
                        anchors.centerIn: parent; spacing: 4
                        Text {
                            text: root.scanning ? "󰑐" : "󰑓"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10; color: "#a6e3a1"
                            anchors.verticalCenter: parent.verticalCenter
                            RotationAnimator on rotation {
                                running: root.scanning; from: 0; to: 360
                                duration: 1000; loops: Animation.Infinite
                            }
                        }
                        Text {
                            text: root.scanning ? "Scan..." : "Refresh"
                            font.pixelSize: 10; color: "#a6e3a1"
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.refresh()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a0a30" }

            Repeater {
                model: root.networks
                Rectangle {
                    width: col.width; height: 40; radius: 8
                    color: modelData.active ? "#0e2a1a" : netArea.containsMouse ? "#0d0520" : "transparent"
                    border.color: modelData.active ? "#a6e3a130" : "transparent"
                    border.width: 1

                    Row {
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        anchors.leftMargin: 8; anchors.rightMargin: 8
                        spacing: 8

                        // Signal icon
                        Text {
                            text: modelData.signal > 75 ? "󰤨" : modelData.signal > 50 ? "󰤥" : modelData.signal > 25 ? "󰤢" : "󰤟"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: modelData.active ? "#a6e3a1" : "#3a2a5a"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 22 - 16 - 20
                            spacing: 1
                            Text {
                                text: modelData.ssid
                                font.pixelSize: 11; font.weight: modelData.active ? Font.Medium : Font.Normal
                                color: modelData.active ? "#e0d0ff" : "#6a5a8a"
                                font.family: "JetBrainsMono Nerd Font"
                                width: parent.width; elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.active ? "Connected" : (modelData.secure ? "Secured" : "Open")
                                font.pixelSize: 9
                                color: modelData.active ? "#a6e3a1" : "#3a2a5a"
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        Text {
                            text: modelData.secure ? "󰌾" : ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10; color: "#3a2a5a"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: netArea; anchors.fill: parent
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!modelData.active) {
                                wifiConnectProc.ssid = modelData.ssid
                                wifiConnectProc.running = false
                                wifiConnectProc.running = true
                            }
                        }
                    }
                }
            }

            Text {
                visible: root.networks.length === 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.scanning ? "Scanning..." : "No networks"
                font.pixelSize: 10; color: "#3a2a5a"
                font.family: "JetBrainsMono Nerd Font"
                height: 30; verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
