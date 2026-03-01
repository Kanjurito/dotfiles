import QtQuick

Item {
    id: root
    height: 16
    property string icon: ""
    property string label: ""
    property string value: ""
    property color valueColor: "#cba6f7"

    Row {
        anchors.fill: parent
        spacing: 6

        Text {
            text: root.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13; color: "#3a2a5a"
            anchors.verticalCenter: parent.verticalCenter
            width: 18
        }
        Text {
            text: root.label
            font.pixelSize: 11; color: "#3a2a5a"
            font.family: "JetBrainsMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
            width: 90
        }
        Text {
            text: root.value
            font.pixelSize: 11; color: root.valueColor
            font.family: "JetBrainsMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            width: parent.width - 114
        }
    }
}
