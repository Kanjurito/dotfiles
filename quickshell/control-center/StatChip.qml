import QtQuick

Item {
    id: root
    height: 44
    property string icon: ""
    property string label: ""
    property string value: ""
    property color color: "#cba6f7"

    Column {
        anchors.centerIn: parent
        spacing: 4

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Text {
                text: root.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12; color: root.color
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.value
                font.pixelSize: 13; font.weight: Font.Bold
                color: root.color; font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.pixelSize: 9; color: "#3a2a5a"
            font.family: "JetBrainsMono Nerd Font"
            font.letterSpacing: 1
        }
    }
}
