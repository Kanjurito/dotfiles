import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData

            screen: modelData
            layer: "top"

            anchors {
                left: true
                top: true
                bottom: true
            }

            width: 54
            margins {
                left: 10
                top: 10
                bottom: 10
            }

            color: "transparent"
            WlrLayershell.namespace: "quickshell-bar"

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // ─── TOP ───────────────────────────────────────
                // Rofi
                BarButton {
                    icon:"󰣇"
                    color: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.exec("rofi -show drun")
                }

                // Terminal (kitty)
                BarButton {
                    icon: ""
                    color: "#89b4fa"
                    fontSize: 20
                    onClicked: Quickshell.exec("kitty")
                }

                // Control center
                BarButton {
                    icon: "󰹯"
                    color: "#89dceb"
                    fontSize: 20
                    onClicked: Quickshell.exec("bash ~/dotfiles/quickshell/control-center/toggle.sh")
                }

                // ─── CENTER ────────────────────────────────────
                Item { Layout.fillHeight: true }

                // MPRIS
                MprisWidget {}

                // Tray
                TrayWidget {}

                // Media panel toggle
                BarButton {
                    icon: "󰎆"
                    color: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.exec("bash ~/.config/quickshell/media-player/toggle.sh")
                }

                Item { Layout.fillHeight: true }
                // ─── BOTTOM ────────────────────────────────────

                // Notifications (swaync)
                NotifWidget {}

                // Volume
                VolumeWidget {}

                // Backlight
                BacklightWidget {}

                // Bluetooth
                BarButton {
                    icon: "󰂯"
                    color: "#89b4fa"
                    fontSize: 16
                    onClicked: Quickshell.exec("blueberry")
                }

                // Network
                NetworkWidget {}

                // Battery
                BatteryWidget {}

                // Network dashboard
                BarButton {
                    icon: "󱂇"
                    color: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.exec("bash ~/.config/quickshell/network-dashboard/toggle.sh")
                }

                // User menu
                BarButton {
                    icon: ""
                    color: "#cba6f7"
                    fontSize: 20
                    onClicked: Quickshell.exec("bash ~/.config/quickshell/user-menu/toggle.sh")
                }

                // Power
                BarButton {
                    icon: ""
                    color: "#f38ba8"
                    fontSize: 20
                    extraMarginTop: 5
                    onClicked: Quickshell.exec("eww -c ~/.config/eww/powermenu/ open --toggle powermenu")
                }
            }
        }
    }
}
