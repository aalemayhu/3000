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
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    // TODO: handle resuming track.
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
        print("playing \(u)")
        let item = AVPlayerItem(url: u)
        self.player = AVPlayer(playerItem: item)
        //        self.player?.volume = NSSound().volume
        self.player?.play()
        playerIndex += 1
    }
    
    func playNextTrack() {
        play(self.playlist)
    }
    
    func tracks() -> [URL] {
        return self.playlist.tracks
    }
    
    func playOrPause() {
        if player?.rate != 0 {
            player?.pause()
        } else {
            player?.play()
        }
    }
}
