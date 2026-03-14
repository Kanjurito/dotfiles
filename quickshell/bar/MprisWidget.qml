import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 46
    implicitHeight: 46

    property MprisPlayer activePlayer: Mpris.players.length > 0 ? Mpris.players[0] : null

    property string playerIcon: {
        if (!activePlayer) return "\uf0386"   // fallback
        const name = (activePlayer.identity ?? "").toLowerCase()
        if (name.includes("spotify")) return ""
        if (name.includes("firefox")) return ""
        return "󰝚"
    }

    visible: activePlayer !== null

    Rectangle {
        anchors.fill: parent
        color: "#f5c2e7"
        radius: width / 2

        Text {
            anchors.centerIn: parent
            text: root.playerIcon
            color: "#1e1e2e"
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    ToolTip {
        visible: mprisMouse.containsMouse && root.activePlayer !== null
        text: root.activePlayer
            ? ((root.activePlayer.trackTitle ?? "") + " — " + (root.activePlayer.trackArtist ?? ""))
            : ""
    }

    MouseArea {
        id: mprisMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (root.activePlayer) root.activePlayer.togglePlaying()
        }
    }

    scale: mprisMouse.pressed ? 0.88 : 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }
}
