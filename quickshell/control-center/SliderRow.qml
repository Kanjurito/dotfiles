import QtQuick

Item {
    id: root
    height: 28
    property string icon: ""
    property real value: 0.5
    property color accentColor: "#cba6f7"
    signal moved(real val)

    Row {
        anchors.fill: parent; spacing: 10

        Text {
            text: root.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15; color: root.accentColor
            anchors.verticalCenter: parent.verticalCenter
            width: 20
        }

        Item {
            width: parent.width - 20 - 10 - 36 - 10; height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: 4; radius: 2
                color: "#1a1030"

                Rectangle {
                    width: parent.width * root.value; height: parent.height; radius: 2
                    color: root.accentColor
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            MouseArea {
                anchors.fill: parent; anchors.margins: -8
                onClicked: mouse => root.moved(Math.max(0, Math.min(1, mouse.x / track.width)))
                onPositionChanged: mouse => {
                    if (pressed) root.moved(Math.max(0, Math.min(1, mouse.x / track.width)))
                }
            }
        }

        Text {
            text: Math.round(root.value * 100) + "%"
            font.pixelSize: 10; color: "#4a3a6a"
            font.family: "JetBrainsMono Nerd Font"
            width: 36; horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
