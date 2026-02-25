import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    required property var modelData

    WlrLayershell.screen: root.modelData
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { right: true; bottom: false }
    margins { right: 150; bottom: 600 }

    implicitWidth: 370
    implicitHeight: 450
    color: "transparent"

    property string imageSource: ""
    property var tags: ["waifu", "neko", "shinobu", "megumin", "bully", "cuddle", "awoo", "smug", "shinobu"]
    property int tagIndex: 0
    property string selectedTag: tags[tagIndex]
    property bool loading: false

    function fetchImage() {
        if (root.loading) return; // Évite les requêtes multiples en parallèle
        root.loading = true
        fetchProc.running = false
        fetchProc.running = true
    }

    Process {
        id: fetchProc
        command: ["curl", "-s", "https://api.waifu.pics/sfw/" + root.selectedTag]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data)
                    if (json.url) {
                        root.imageSource = json.url
                    }
                } catch(e) {
                    console.log("Erreur de parsing:", e)
                }
                root.loading = false
            }
        }
    }

    Timer {
        interval: 120000; running: true; repeat: true
        onTriggered: root.fetchImage()
    }

    Component.onCompleted: Qt.callLater(function() { root.fetchImage() })

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: "#0a0a12"
        border.color: "#2a1a4a"
        border.width: 1
        clip: true

        Rectangle {
            anchors.centerIn: parent
            width: 40; height: 40; radius: 20
            color: "transparent"
            border.color: "#cba6f7"; border.width: 3
            visible: root.loading

            RotationAnimator on rotation {
                running: root.loading
                from: 0; to: 360; duration: 800
                loops: Animation.Infinite
            }
        }

        Image {
            id: waifuImg
            anchors.fill: parent
            source: root.imageSource
            fillMode: Image.PreserveAspectCrop
            visible: !root.loading && root.imageSource !== ""

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: waifuImg.width; height: waifuImg.height; radius: 15
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.tagIndex = (root.tagIndex + 1) % root.tags.length
                root.selectedTag = root.tags[root.tagIndex]
                root.fetchImage()
            }
        }
    }
}
