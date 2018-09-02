//
//  PlayerManager.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

class PlayerManager {
    
    private var playlist: Playlist
    private var player: AVPlayer?
    private var currentPlaylist: Playlist?
    private var playerIndex = 0
    
    private var playItem: AVPlayerItem?
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    // TODO: handle resuming track time
    // TODO: add random toggle
    // Player tracking
    
    func startPlaylist() {
        NotificationCenter.default.post(name: Notification.Name.StartFirstPlaylist, object: nil)
        play(self.playlist, time: nil)
    }
    
    // TODO: drop argument playlist
    private func play(_ playlist: Playlist, time: CMTime?) {
        guard playlist.tracks.count > 0 && playerIndex != playlist.tracks.count - 1 else {
            debug_print("END reached, what now?")
            playerIndex = 0
            return
        }
        
        let u = playlist.tracks[playerIndex]
        self.playItem = AVPlayerItem(url: u)
        if let item = self.playItem {
            self.player = AVPlayer(playerItem: item)
            if let seekTime = time {
                self.player?.seek(to: seekTime)
            }
            self.player?.play()
            NotificationCenter.default.post(name: Notification.Name.StartPlayingItem, object: nil)
        }
    }
    
    func playFrom(_ index: Int) {
        self.playerIndex = index
        self.player?.pause()
        self.play(self.playlist, time: nil)
    }
    
    func playNextTrack() {
        playerIndex += 1
        play(self.playlist, time: nil)
    }
    
    func tracks() -> [URL] {
        return self.playlist.tracks
    }
    
    func playOrPause() {
        let lastTrack = StoredDefaults.getLastTrack(playlist: self.playlist)
        let seekTime = StoredDefaults.seekTime(playlist: self.playlist)
        
        // Attempt to resume previous track
        let didResume = self.resume(lastTrack, time: seekTime)
        if didResume {
            // Clear out the last track, it's already handled by saveState(...)
            StoredDefaults.save(folder: playlist.folder, data: playerState(lastTrack: ""))
            return
        }
        
        if lastTrack != nil {
            // Prevent playing reference to old track
            StoredDefaults.save(folder: playlist.folder, data: playerState(lastTrack: ""))
        }

        if isPlaying() {
            // Pause since user is already playing a track
            player?.pause()
        } else if playItem != nil {
            // Resume the loaded track
            player?.play()
        } else {
            // Start from the beginning
            self.play(self.playlist, time: nil)
        }
    }
    
    func saveState() {
        let lastTrack = self.playlist.tracks[playerIndex].absoluteString
        StoredDefaults.save(folder: playlist.folder, data: playerState(lastTrack: lastTrack))
    }
    
    func isPlaying() -> Bool {
        return self.playItem != nil && player?.rate != 0
    }
    
    func currentTrack() -> AVPlayerItem? {
        return self.playItem
    }
    
    private func resume(_ url: URL?, time: CMTime?) -> Bool{
        guard let url = url, playlist.tracks.contains(url),
            let index = playlist.tracks.index(of: url) else {
                // Make sure the track is present
                // Could be missing for any reason, f. ex. user deleted file
                return false
        }
        self.playerIndex = index
        self.play(self.playlist, time: time)
        return true
    }
    
    private func playerState(lastTrack: String) -> Any {
        let currentItem = self.player?.currentTime()
        var data: [String: Any] = [
            StoredDefaults.LastTrackKey: lastTrack
        ]
        
        // Save the player time
        if let seconds = currentItem?.seconds,
            let timescale = currentItem?.timescale {
            data[StoredDefaults.PlaybackTimeKey] = [
                StoredDefaults.SecondsKey: seconds,
                StoredDefaults.TimeScaleKey: timescale
            ]
        }
        return data
    }
    
    func resetPlayerState() {
        self.player?.pause()
        self.playerIndex = 0
        StoredDefaults.save(folder: playlist.folder, data: [])
    }
}
