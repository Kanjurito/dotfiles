import QtQuick
import QtQuick.Effects

Item {
    id: root
    height: 52
    property string icon: ""
    property string label: ""
    property string sublabel: ""
    property bool active: false
    property bool hasMenu: false
    signal toggled()

    Rectangle {
        anchors.fill: parent; radius: 10
        color: root.active ? "#1a0a30" : "#0d0520"
        border.color: root.active ? "#cba6f740" : "#2a1a4a"
        border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } }

        // Active glow
        layer.enabled: root.active
        layer.effect: MultiEffect {
            shadowEnabled: true; shadowColor: "#30cba6f7"
            shadowBlur: 0.5
        }

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            anchors.leftMargin: 10
            spacing: 8

            Rectangle {
                width: 28; height: 28; radius: 14
                color: root.active ? "#cba6f7" : "#1a1030"
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: root.icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    color: root.active ? "#0a0a12" : "#4a3a6a"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: root.label
                    font.pixelSize: 11; font.weight: Font.Medium
                    color: root.active ? "#e0d0ff" : "#6a5a8a"
                    font.family: "JetBrainsMono Nerd Font"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                Text {
                    text: root.sublabel
                    font.pixelSize: 9; color: "#3a2a5a"
                    font.family: "JetBrainsMono Nerd Font"
                    width: 80; elide: Text.ElideRight
                }
            }
        }
    }

    Text {
        visible: root.hasMenu
        anchors { right: parent.right; bottom: parent.bottom }
        anchors.rightMargin: 8; anchors.bottomMargin: 8
        text: "󰅂"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 8; color: "#3a2a5a"
    }

    MouseArea {
        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
