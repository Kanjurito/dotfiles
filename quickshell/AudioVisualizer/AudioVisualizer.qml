import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property var modelData

    // --- WAYLAND LAYER SHELL CONFIG ---
    WlrLayershell.screen: root.modelData
    WlrLayershell.layer: WlrLayer.Bottom            // Stay behind windows
    WlrLayershell.exclusionMode: ExclusionMode.Ignore // Don't push windows away
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { bottom: true; left: true; right: true }
    implicitHeight: 120
    color: "transparent"

    // Visualizer settings
    property int barCount: 48
    property var barValues: Array(48).fill(0)
    // Default colors (will be overwritten by Wallust)
    property color c0: "#4895A5"
    property color c1: "#AD6581"

    // Function to parse Wallust color sequences
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

    // Initial load of Wallust colors
    Process {
        command: ["cat", os.home + "/.cache/wallust/sequences"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => root.parseSequences(data)
        }
    }

    // Watch for wallpaper/color changes using inotify
    Process {
        id: watcher
        command: ["inotifywait", "-m", "-e", "close_write",
                  os.home + "/.cache/wallust/sequences"]
        running: true
        stdout: SplitParser {
            onRead: _ => { reloader.running = false; reloader.running = true }
        }
    }

    // Reload colors when the file is modified
    Process {
        id: reloader
        command: ["cat", os.home + "/.cache/wallust/sequences"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { root.parseSequences(data); reloader.running = false }
        }
    }

    // Bridge to read CAVA raw data from the FIFO pipe via Python
    Process {
        id: cavaReader
        command: ["python3", "/home/alterra/.config/quickshell/AudioVisualizer/cava-reader.py",
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

    // Restart mechanism if CAVA reader crashes
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

    // UI Rendering: Row of bars
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
                // Scale bar height based on CAVA value (0-255)
                height: Math.max(2, (root.barValues[index] / 255.0) * barsRow.height)
                anchors.bottom: parent.bottom
                radius: 2
                // Gradient color interpolation between root.c0 and root.c1
                color: {
                    var t = index / (root.barCount - 1)
                    return Qt.rgba(
                        root.c0.r + t * (root.c1.r - root.c0.r),
                        root.c0.g + t * (root.c1.g - root.c0.g),
                        root.c0.b + t * (root.c1.b - root.c0.b),
                        0.45 + (root.barValues[index] / 255.0) * 0.55
                    )
                }
                // Smooth animations for transitions
                Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                Behavior on color  { ColorAnimation  { duration: 800 } }
            }
        }
    }
}