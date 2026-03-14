import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: trayColumn.implicitHeight + 30

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.19, 0.20, 0.26, 0.5)
        radius: 24
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        ColumnLayout {
            id: trayColumn
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: SystemTray.items

                Item {
                    id: trayItem
                    required property SystemTrayItem modelData

                    implicitWidth: 26
                    implicitHeight: 26
                    Layout.alignment: Qt.AlignHCenter

                    Image {
                        anchors.fill: parent
                        source: trayItem.modelData.icon
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    QsMenuAnchor {
                        id: menuAnchor
                        menu: trayItem.modelData.menu
                        anchor.item: trayItem
                        anchor.edges: Edges.Bottom | Edges.Right
                    }

                    ToolTip {
                        visible: trayMouse.containsMouse
                        text: trayItem.modelData.tooltip ?? trayItem.modelData.title ?? ""
                    }

                    MouseArea {
                        id: trayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton && trayItem.modelData.menu) {
                                menuAnchor.open()
                            } else {
                                trayItem.modelData.activate()
                            }
                        }
                    }
                }
            }
        }
    }
}
