import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: ClockWidget { screen: modelData }
    }
}
