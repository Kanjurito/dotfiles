import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property var modelData

    WlrLayershell.screen: root.modelData
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { bottom: true; left: true; right: true }
    implicitHeight: 120
    color: "transparent"

    property int barCount: 48
    property var barValues: Array(48).fill(0)
    property color c0: "#4895A5"
    property color c1: "#AD6581"

    function parseSequences(data) {
        try {
            var colors = {}
            var re = /4;(\d+);(#[0-9a-fA-F]{6})/g
            var m
            while ((m = re.exec(data)) !== null)
                colors[parseInt(m[1])] = m[2]
            if (colors[4]) root.c0 = colors[4]
            if (colors[2]) root.c1 = colors[2]
        } catch(e) {}
    }

    Process {
        command: ["cat", "/home/alterra/.cache/wallust/sequences"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => root.parseSequences(data)
        }
    }

    Process {
        id: watcher
        command: ["inotifywait", "-m", "-e", "close_write",
                  "/home/alterra/.cache/wallust/sequences"]
        running: true
        stdout: SplitParser {
            onRead: _ => { reloader.running = false; reloader.running = true }
        }
    }

    Process {
        id: reloader
        command: ["cat", "/home/alterra/.cache/wallust/sequences"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { root.parseSequences(data); reloader.running = false }
        }
    }

    // Lit le FIFO via python qui convertit les bytes en texte lisible
    Process {
        id: cavaReader
        command: ["python3", "/home/alterra/dotfiles/quickshell/AudioVisualizer/cava-reader.py",
                  "/tmp/cava.fifo", "48"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                var parts = line.trim().split(" ")
                if (parts.length < 2) return
                var vals = Array(root.barCount).fill(0)
                for (var i = 0; i < Math.min(parts.length, root.barCount); i++)
                    vals[i] = parseInt(parts[i]) || 0
                root.barValues = vals
            }
        }
    }

    Timer {
        interval: 2000
        repeat: false
        id: restartTimer
        onTriggered: cavaReader.running = true
    }

    Connections {
        target: cavaReader
        function onRunningChanged() {
            if (!cavaReader.running) restartTimer.start()
        }
    }

    Row {
        id: barsRow
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: parent.height
        spacing: 3

        Repeater {
            model: root.barCount
            Rectangle {
                required property int index
                width:  (barsRow.width - (root.barCount - 1) * barsRow.spacing) / root.barCount
                height: Math.max(2, (root.barValues[index] / 255.0) * barsRow.height)
                anchors.bottom: parent.bottom
                radius: 2
                color: {
                    var t = index / (root.barCount - 1)
                    return Qt.rgba(
                        root.c0.r + t * (root.c1.r - root.c0.r),
                        root.c0.g + t * (root.c1.g - root.c0.g),
                        root.c0.b + t * (root.c1.b - root.c0.b),
                        0.45 + (root.barValues[index] / 255.0) * 0.55
                    )
                }
                Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                Behavior on color  { ColorAnimation  { duration: 800 } }
            }
        }
    }
}
