import QtQuick
import QtQuick.Layouts


Item {
    id: root

    property string icon: ""
    property color iconColor: "#cdd6f4"
    property int fontSize: 16
    property int extraMarginTop: 0

    signal clicked()
    signal scrollUp()
    signal scrollDown()

    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: extraMarginTop
    implicitWidth: 46
    implicitHeight: 46

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#1e1e2e"
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1
        radius: 24

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.05)
            visible: mouseArea.containsMouse
        }

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.iconColor
            font.pixelSize: root.fontSize
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: root.clicked()

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) root.scrollUp()
            else root.scrollDown()
        }
    }

    scale: mouseArea.pressed ? 0.88 : 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }
}
