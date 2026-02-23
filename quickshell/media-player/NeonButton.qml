// ~/.config/quickshell/media-player/NeonButton.qml
import QtQuick
import QtQuick.Effects

Item {
    id: root

    property string icon: ""
    property int iconSize: 16
    property bool active: false
    property bool glowing: false
    property color activeColor: "#89b4fa"
    signal clicked()

    Rectangle {
        id: bg
        anchors.centerIn: parent
        width: Math.min(root.width, root.height) - 4
        height: width
        radius: width / 2
        color: root.active ? Qt.rgba(
            activeColor.r, activeColor.g, activeColor.b, 0.12
        ) : "transparent"
        border.color: root.active ? Qt.rgba(
            activeColor.r, activeColor.g, activeColor.b, 0.3
        ) : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: root.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: root.iconSize
            color: root.active ? root.activeColor : "#3a3a65"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        layer.enabled: root.glowing && root.active
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.6)
            shadowBlur: 0.7
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0
        }

        scale: mouseArea.pressed ? 0.88 : 1
        Behavior on scale { NumberAnimation { duration: 80 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled !== false
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()

        hoverEnabled: true
        onEntered: bg.color = root.active
            ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.18)
            : Qt.rgba(1, 1, 1, 0.04)
        onExited: bg.color = root.active
            ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.12)
            : "transparent"
    }
}
