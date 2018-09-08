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
    
    // TODO: persist volume value
    private var volume: Float {
        didSet {
            self.player?.volume = volume
        }
    }

    var player: AVPlayer?

    public static let AssetOptions = [
        AVURLAssetPreferPreciseDurationAndTimingKey: true
    ]
    
    init(playlist: Playlist) {
        self.playlist = playlist
        self.storage = StoredDefaults(folder: playlist.folder)
        self.volume = self.storage.getVolumeLevel() ?? 0.3
        super.init()
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
            // Use previous volume
            self.player?.volume = volume
            if let seekTime = time {
                self.player?.seek(to: seekTime)
            }
            self.player?.play()
            NotificationCenter.default.post(name: Notification.Name.StartPlayingItem, object: nil)
        }
    }
    
    func changeVolume(change: Float) {
        guard let player = self.player else {
            self.volume = self.volume+change < 0 ? 0 : self.volume + change
            self.volume = self.volume > 1 ? 1 : self.volume
            return
        }
        self.volume = player.volume+change < 0 ? 0 : player.volume + change
        self.volume = self.volume > 1 ? 1 : self.volume
    }
    
    func getVolume() -> Float? {
        return self.volume
    }
    
    func getIndex() -> Int {
        return playerIndex
    }
    
    func playFrom(_ index: Int) {
        debug_print("\(#function): \(index)")
        self.playerIndex = index
        self.player?.pause()
        self.play(time: nil)
    }
    
    func playNextTrack() {
        self.storage.removeLastTrack()
        playerIndex += 1
        play(time: nil)
    }
    
    func playPreviousTrack() {
        self.storage.removeLastTrack()
        guard playerIndex > 0 else { return }
        playerIndex += -1
        play(time: nil)
    }
    
    func mute() {
        guard let player = self.player else {
            return
        }
        player.isMuted = !player.isMuted
    }
    
    func playRandomTrack() {
        self.storage.removeLastTrack()
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
    
    func useCache(playlist: Playlist) {
        self.playlist = playlist
        
        if let url = self.storage.getLastTrack(),
            let index = self.indexFor(url: url, playlist: playlist) {
            self.playerIndex = index
        } else {
            self.storage.change(folder: playlist.folder)
        }
        self.volume = self.storage.getVolumeLevel() ?? self.volume
    }
    
    func playOrPause() {
        let lastTrack = self.storage.getLastTrack()
        let seekTime = self.storage.seekTime(playlist: self.playlist)
        
        // Attempt to resume previous track
        let didResume = self.resume(lastTrack, time: seekTime)        
        guard !didResume else {
            self.storage.removeLastTrack()
            return
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
        storage.save(folder: playlist.folder, data: playerState(lastTrack: lastTrack))
    }
    
    func isPlaying() -> Bool {
        return self.playItem != nil && player?.rate != 0
    }
    
    func currentTrack() -> AVPlayerItem? {
        return self.playItem
    }
    
    func indexFor(url: URL, playlist: Playlist) -> Int? {
        guard playlist.tracks.contains(url) else {
            return nil
        }        
        return playlist.tracks.index(of: url)
    }
    
    private func resume(_ url: URL?, time: CMTime?) -> Bool{
        guard let url = url, let index = self.indexFor(url: url, playlist: self.playlist) else {
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
        var data: [String: Any?] = [
            StoredDefaults.LastTrackKey: lastTrack,
            StoredDefaults.VolumeLevel: volume
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
        storage.save(folder: playlist.folder, data: [StoredDefaults.VolumeLevel: volume])
    }
    
    func playTime(index: Int? = nil) -> (currentTime: CMTime?, duration: CMTime?) {
        if let index = index,
            self.indexFor(url: self.tracks()[index], playlist: self.playlist) == index {
            let currentTime = self.storage.seekTime(playlist: self.playlist)
            return (currentTime, AVURLAsset(url: self.tracks()[index], options: PlayerManager.AssetOptions).duration)

        }
        return (self.playItem?.currentTime(), self.playItem?.asset.duration)
    }
    
    // Notifications
    
    @objc func didFinishPlaying(note: NSNotification) {
        guard isLooping else { return }
        self.play(time: nil)
    }
}
