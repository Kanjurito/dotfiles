pragma Singleton
import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    property MprisPlayer activePlayer: null

    // Propriétés dérivées avec protection null
    readonly property string title: activePlayer ? activePlayer.trackTitle ?? "No track" : "No track"
    readonly property string artist: activePlayer ? activePlayer.trackArtist ?? "" : ""
    readonly property string album: activePlayer ? activePlayer.trackAlbum ?? "" : ""
    readonly property string artUrl: activePlayer ? activePlayer.trackArtUrl ?? "" : ""
    readonly property bool playing: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
    readonly property real position: activePlayer ? activePlayer.position ?? 0 : 0
    readonly property real length: activePlayer ? activePlayer.trackLength ?? 0 : 0
    readonly property real volume: activePlayer ? activePlayer.volume ?? 1 : 1
    readonly property bool shuffled: activePlayer ? activePlayer.shuffle ?? false : false
    readonly property int loopState: activePlayer ? activePlayer.loopState : 0

    Connections {
        target: Mpris
        function onPlayersChanged() { root.pickPlayer() }
    }

    Component.onCompleted: {
        console.log("MprisData initialized, players:", Mpris.players.length)
        pickPlayer()
    }

    function pickPlayer() {
        const players = Mpris.players
        console.log("pickPlayer called, count:", players.length)
        for (let i = 0; i < players.length; i++) {
            const p = players[i]
            console.log("  player", i, ":", p.identity, "state:", p.playbackState)
            if (p.playbackState === MprisPlaybackState.Playing) {
                activePlayer = p
                console.log("  -> selected (playing)")
                return
            }
        }
        activePlayer = players.length > 0 ? players[0] : null
        console.log("  -> selected first or null:", activePlayer ? activePlayer.identity : "null")
    }

    function playPause() { if (activePlayer) activePlayer.togglePlaying() }
    function next() { if (activePlayer) activePlayer.next() }
    function previous() { if (activePlayer) activePlayer.previous() }
    function seek(pos) { if (activePlayer) activePlayer.position = pos }
    function setVolume(v) { if (activePlayer) activePlayer.volume = v }
    function setShuffle(val) { if (activePlayer) activePlayer.shuffle = val }
    function setLoop(val) { if (activePlayer) activePlayer.loopState = val }
}
