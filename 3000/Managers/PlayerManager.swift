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
    // Move isLooping into player state
    private var isLooping = false
    private var playItem: AVPlayerItem?
    private var storage: StoredDefaults
    
    private var state = PlayerState()
    
    private var volume: Float {
        didSet {
            self.player?.volume = volume
            self.state.volume = volume
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
    
    override init() {
        self.playlist = Playlist()
        self.storage = StoredDefaults(folder: self.playlist.folder)
        self.volume = 0.3
        super.init()
    }
    
    // Player tracking
    
    private func isEndOfPlaylist() -> Bool {
        guard playlist.size() > 0 && self.state.playerIndex < playlist.size() else {
                    self.state.playerIndex = 0
                    return true
        }
        
        return false
    }
    
    func startPlaylist() {
        NotificationCenter.default.post(name: Notification.Name.StartPlaylist, object: nil)
        play(time: nil)
    }
    
    private func play(time: CMTime?) {
        guard !isEndOfPlaylist() else {
            debug_print("END reached, what now?")
            return
        }
        
        let u = playlist.track(at: self.state.playerIndex)
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
    
    func getVolume() -> Float {
        return self.volume
    }
    
    func getIndex() -> Int {
        return state.playerIndex
    }
    
    func playFrom(_ index: Int) {
        debug_print("\(#function): \(index)")
        self.state.playerIndex = index
        self.player?.pause()
        self.play(time: nil)
    }
    
    func playNextTrack() {
        self.storage.removeLastTrack()
        self.state.playerIndex += 1
        play(time: nil)
    }
    
    func playPreviousTrack() {
        self.storage.removeLastTrack()
        guard self.state.playerIndex > 0 else { return }
        self.state.playerIndex += -1
        play(time: nil)
    }
    
    func mute() {
        guard let player = self.player else { return }
        player.isMuted = !player.isMuted
    }
    
    func playRandomTrack() {
        self.storage.removeLastTrack()
        let upperBound = UInt32(self.playlist.size())
        self.state.playerIndex = Int(arc4random_uniform(upperBound))
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
    
    func useCache(playlist: Playlist) -> Error? {
        self.playlist = playlist
        if let error = self.storage.change(folder: playlist.folder) {
            return error
        }
        if let url = self.storage.getLastTrack(),
            let index = self.indexFor(url: url, playlist: playlist) {
            self.state.playerIndex = index
        }
        self.volume = self.storage.getVolumeLevel() ?? self.volume
        return nil
    }
    
    func playOrPause() {
        let _ = self.saveState()
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
    
    func saveState() -> Error? {
        self.state.update(time: self.player?.currentTime(), track: self.playlist.track(at: self.state.playerIndex).absoluteString)
        return storage.save(folder: playlist.folder, data: state.jsonData()).error
    }
    
    func isPlaying() -> Bool {
        return self.playItem != nil && player?.rate != 0
    }
    
    func currentTrack() -> AVPlayerItem? {
        return self.playItem
    }
    
    func indexFor(url: URL, playlist: Playlist) -> Int? {
        guard playlist.contains(track: url) else {
            return nil
        }        
        return playlist.index(of: url)
    }
    
    private func resume(_ url: URL?, time: CMTime?) -> Bool{
        guard let url = url, let index = self.indexFor(url: url, playlist: self.playlist) else {
                return false
        }
        self.state.playerIndex = index
        self.play(time: time)
        return true
    }
    
    // resetPlayerState used when changing playlist
    func resetPlayerState() -> Error? {
        self.player?.pause()
        self.state.reset()
        return storage.save(folder: playlist.folder, data: state.jsonData()).error
    }
    
    func playTime(index: Int? = nil) -> (currentTime: CMTime?, duration: CMTime?) {
        guard let index = index else { return (nil, nil) }
        // TODO: clean up below conditional statement
        if self.indexFor(url: self.playlist.track(at: index), playlist: self.playlist) == index {
            let currentTime = self.storage.seekTime(playlist: self.playlist)
            return (currentTime, AVURLAsset(url: self.playlist.track(at: index), options: PlayerManager.AssetOptions).duration)
        }
        return (self.playItem?.currentTime(), self.playItem?.asset.duration)
    }
    
    // Notifications
    
    @objc func didFinishPlaying(note: NSNotification) {
        guard isLooping else { return }
        self.play(time: nil)
    }
}
