//
//  PlayerManager.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

class PlayerManager: NSObject {
    
    private var playlist: Playlist
    private var playerIndex = 0
    private var isLooping = false
    private var playItem: AVPlayerItem?
    private var storage: StoredDefaults

    var player: AVPlayer?

    
    init(playlist: Playlist) {
        self.playlist = playlist
        self.storage = StoredDefaults(folder: playlist.folder)
    }
    
    // TODO: handle resuming track time
    // TODO: add random toggle
    // Player tracking
    
    func startPlaylist() {
        NotificationCenter.default.post(name: Notification.Name.StartFirstPlaylist, object: nil)
        play(time: nil)
    }
    
    // TODO: drop argument playlist
    private func play(time: CMTime?) {
        guard playlist.tracks.count > 0 && playerIndex < playlist.tracks.count else {
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
    
    func changeVolume(change: Float) {
        guard let player = self.player else {
            return
        }
        player.volume = player.volume+change < 0 ? 0 : player.volume + change
    }
    
    func getVolume() -> Float? {
        guard let player = self.player else {
            return nil
        }
        return player.volume
    }
    
    func setVolume(volume: Float) {
        guard let player = self.player else {
            return
        }
        player.volume = volume
    }
    
    func playFrom(_ index: Int) {
        debug_print("\(#function): \(index)")
        self.playerIndex = index
        self.player?.pause()
        self.play(time: nil)
    }
    
    func playNextTrack() {
        playerIndex += 1
        play(time: nil)
    }
    
    func playRandomTrack() {
        let upperBound = UInt32(self.playlist.tracks.count)
        playerIndex = Int(arc4random_uniform(upperBound))
        self.play(time: nil)
    }
    
    func loopTrack() {
        isLooping = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func getIsLooping() -> Bool{
        return isLooping
    }
    
    func stopLooping() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        isLooping = false
    }
    
    func tracks() -> [URL] {
        return self.playlist.tracks
    }
    
    func playOrPause() {
        let lastTrack = self.storage.getLastTrack(playlist: self.playlist)
        let seekTime = self.storage.seekTime(playlist: self.playlist)
        
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
            self.play(time: nil)
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
        self.play(time: time)
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
    
    func playTime() -> (currentTime: CMTime?, duration: CMTime?) {
        return (self.playItem?.currentTime(), self.playItem?.duration)
    }
    
    // Notifications
    
    @objc func didFinishPlaying(note: NSNotification) {
        guard isLooping else { return }
        self.play(time: nil)
    }
}
