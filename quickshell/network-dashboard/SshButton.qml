import Quickshell.Io
import QtQuick
import QtQuick.Effects

Item {
    id: root
    height: 32
    property string label: ""
    property string host: ""
    property string icon: "󰣇"
    property color color: "#89b4fa"

    Process {
        id: sshProc
        command: ["alacritty", "-e", "ssh", "-o", "StrictHostKeyChecking=no", root.host]
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: area.containsMouse ? Qt.rgba(
            parseInt(root.color.toString().slice(1,3), 16)/255 * 0.15,
            parseInt(root.color.toString().slice(3,5), 16)/255 * 0.15,
            parseInt(root.color.toString().slice(5,7), 16)/255 * 0.15, 1
        ) : "#0d0520"
        border.color: root.color + "40"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 100 } }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: root.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14; color: root.color
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.label
                font.pixelSize: 11; color: root.color
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.host
                font.pixelSize: 9; color: root.color + "80"
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            anchors.right: parent.right; anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "󰁔"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12; color: root.color + "60"
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: sshProc.running = true
    }
}
