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
        play(self.playlist)
    }
    
    private func play(_ playlist: Playlist) {
        guard playlist.tracks.count > 0 && playerIndex != playlist.tracks.count - 1 else {
            print("END reached, what now?")
            playerIndex = 0
            return
        }
        
        let u = playlist.tracks[playerIndex]
        self.playItem = AVPlayerItem(url: u)
        if let item = self.playItem {
            self.player = AVPlayer(playerItem: item)
            //        self.player?.volume = NSSound().volume
            self.player?.play()
            playerIndex += 1
            NotificationCenter.default.post(name: Notification.Name.StartPlayingItem, object: nil)
        }
    }
    
    func playNextTrack() {
        play(self.playlist)
    }
    
    func tracks() -> [URL] {
        return self.playlist.tracks
    }
    
    func playOrPause() {
        if !isPlaying() {
            startOrResumeLastTrack()
        } else {
            player?.play()
        }
    }
    
    func saveLastTrack() {
        guard isPlaying() else { return }
        UserDefaults.standard.set(self.playlist.tracks[playerIndex], forKey: StoredDefaults.LastTrack)
    }
    
    func isPlaying() -> Bool {
        return self.playItem != nil && player?.rate != 0
    }
    
    func startOrResumeLastTrack() {
        guard let url = UserDefaults.standard.url(forKey: StoredDefaults.LastTrack) else {
            playerIndex = 0
            play(self.playlist)
            return
        }
        
        // Clear last track
        UserDefaults.standard.set(nil, forKey: StoredDefaults.LastTrack)
        
        if !playlist.tracks.contains(url) { return }
        
        playerIndex = 0
        for t in playlist.tracks {
            if t == url { break }
            playerIndex = playerIndex + 1
        }
    }
    
    func currentTrack() -> AVPlayerItem? {
        return self.playItem
    }
}
