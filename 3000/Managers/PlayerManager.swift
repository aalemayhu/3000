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
            print("END reached, what now?")
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
        if let track = lastTrack {
            // There is a stored track
            self.resume(track, time: seekTime)
        } else if isPlaying() {
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
    
    func saveLastTrack() {
        guard isPlaying() else { return }
        print("\(#function)")
        StoredDefaults.save(folder: playlist.folder, data: jsonPayload())
    }
    
    func isPlaying() -> Bool {
        return self.playItem != nil && player?.rate != 0
    }
    
    func currentTrack() -> AVPlayerItem? {
        return self.playItem
    }
    
    private func resume(_ url: URL, time: CMTime?) {
        // Make sure the track is present
        if !playlist.tracks.contains(url) {
            fatalError("Unhandled error missing track \(url)")
        }
        
        if let index = playlist.tracks.firstIndex(of: url) {
            self.playerIndex = index
            self.play(self.playlist, time: time)
        } else {
            fatalError("Unhandled error no match for track \(url)")
        }
    }
    
    private func jsonPayload() -> Any {
        let currentItem = self.player?.currentTime()
        let seconds = currentItem?.getSeconds()
        let timescale = currentItem?.timescale
        
        let data: [String: Any] = [
            StoredDefaults.LastTrackKey: self.playlist.tracks[playerIndex].absoluteString,
            StoredDefaults.PlaybackTimeKey: [
                StoredDefaults.SecondsKey: seconds!,
                StoredDefaults.TimeScaleKey: timescale!
            ],
            ]
        return data
    }
}
