import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick

ShellRoot {
    id: shellRoot

    property MprisPlayer activePlayer: null

    // UntypedObjectModel : signaux objectInsertedPost / objectRemovedPost
    Connections {
        target: Mpris.players
        function onObjectInsertedPost() { shellRoot.pickPlayer() }
        function onObjectRemovedPost() { shellRoot.pickPlayer() }
    }

    Component.onCompleted: Qt.callLater(pickPlayer)

    function pickPlayer() {
        const vals = Mpris.players.values
        console.log("pickPlayer, values:", vals, "type:", typeof vals)
        if (!vals) { activePlayer = null; return }
        let best = null
        for (let i = 0; i < vals.length; i++) {
            const p = vals[i]
            console.log("  player", i, p.identity, "state:", p.playbackState)
            if (p.playbackState === MprisPlaybackState.Playing) { best = p; break }
            if (!best) best = p
        }
        activePlayer = best
        console.log("activePlayer:", activePlayer ? activePlayer.identity : "null")
    }

    MediaPlayerWindow {
        id: playerWindow
        player: shellRoot.activePlayer
        onPlayerSwitch: function(index) {
            const vals = Mpris.players.values
            if (vals && index < vals.length) shellRoot.activePlayer = vals[index]
        }
    }

    IpcHandler {
        target: "toggle"
        function onMessage() {
            playerWindow.visible = !playerWindow.visible
        }
    }
}
