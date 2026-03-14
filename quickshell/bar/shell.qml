//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData

            screen: modelData
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell-bar"

            anchors {
                left: true
                top: true
                bottom: true
            }

            implicitWidth: 54
            margins {
                left: 10
                top: 10
                bottom: 10
            }

            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // ─── TOP ───────────────────────────────────────

                // Rofi
                BarButton {
                    icon: ""
                    iconColor: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["rofi", "-show", "drun"])
                }

                // Kitty
                BarButton {
                    icon: ""
                    iconColor: "#89b4fa"
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["kitty"])
                }

                // Control center
                BarButton {
                    icon: "󰹯"
                    iconColor: "#89dceb"
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["sh", "-c", "bash ~/dotfiles/quickshell/control-center/toggle.sh"])
                }

                // ─── CENTER ────────────────────────────────────
                Item { Layout.fillHeight: true }

                MprisWidget {}
                TrayWidget {}

                // Media toggle
                BarButton {
                    icon: "󰎆"
                    iconColor: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["sh", "-c", "bash ~/.config/quickshell/media-player/toggle.sh"])
                }

                Item { Layout.fillHeight: true }

                // ─── BOTTOM ────────────────────────────────────
                NotifWidget {}
                VolumeWidget {}
                BacklightWidget {}

                // Bluetooth
                BarButton {
                    icon: "󰂯"
                    iconColor: "#89b4fa"
                    fontSize: 16
                    onClicked: Quickshell.execDetached(["blueberry"])
                }

                NetworkWidget {}
                BatteryWidget {}

                // Network dashboard
                BarButton {
                    icon: "󱂇"
                    iconColor: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["sh", "-c", "bash ~/.config/quickshell/network-dashboard/toggle.sh"])
                }

                // User menu
                BarButton {
                    icon: ""
                    iconColor: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["sh", "-c", "bash ~/.config/quickshell/user-menu/toggle.sh"])
                }

                // Power
                BarButton {
                    icon: ""
                    iconColor: "#f38ba8"
                    fontSize: 20
                    extraMarginTop: 5
                    onClicked: Quickshell.execDetached(["sh", "-c", "eww -c ~/.config/eww/powermenu/ open --toggle powermenu"])
                }
            }
        }
    }
}
