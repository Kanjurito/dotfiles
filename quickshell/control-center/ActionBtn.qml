import QtQuick

Rectangle {
    id: root
    width: 28; height: 28; radius: 8
    property string icon: ""
    property color accent: "#4a3a6a"
    signal clicked()

    color: area.containsMouse ? Qt.lighter(accent, 1.3) : "#0d0520"
    border.color: accent + "40"; border.width: 1
    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13; color: root.accent
    }
    MouseArea {
        id: area; anchors.fill: parent
        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
