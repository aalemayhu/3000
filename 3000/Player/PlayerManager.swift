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
    private var playItem: AVPlayerItem?
    private var storage: PlayerConfiguration
    private var state = PlayerState()
    
    static let DefaultVolumeValue: Float = 0.04
    
    private var volume: Float {
        didSet {
            self.player?.volume = volume
            self.state.volume = volume
        }
    }

    private var isMuted = false  {
        didSet {
            guard let player = self.player else { return }
            player.isMuted = !player.isMuted
        }
    }

    var player: AVPlayer?

    public static let AssetOptions = [
        AVURLAssetPreferPreciseDurationAndTimingKey: true
    ]
    
    init(playlist: Playlist) {
        self.playlist = playlist
        self.storage = PlayerConfiguration(folder: playlist.folder)
        self.volume = self.storage.getVolumeLevel() ?? PlayerManager.DefaultVolumeValue
        super.init()
    }
    
    override init() {
        self.playlist = Playlist()
        self.storage = PlayerConfiguration(folder: self.playlist.folder)
        self.volume = PlayerManager.DefaultVolumeValue
        super.init()
    }
    
    // Player tracking
    
    private func isEndOfPlaylist() -> Bool {
        return !(self.state.currentIndex < playlist.size())
    }
    
    func startPlaylist() {
        NotificationCenter.default.post(name: Notification.Name.StartPlaylist, object: nil)
        play(time: nil)
    }
    
    private func play(time: CMTime?) {
        guard playlist.size() > 0 else { return }
        if isEndOfPlaylist() {
            self.state.reset()
        }
        
        let u = playlist.tracks[self.state.currentIndex]
        self.playItem = AVPlayerItem(url: u)
        if let item = self.playItem {
            self.player = AVPlayer(playerItem: item)
            // Use previous volume
            self.player?.volume = volume
            if let seekTime = time {
                self.player?.seek(to: seekTime)
            }
            self.player?.isMuted = self.isMuted
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
    
    func setVolume(v: Float) {
        debug_print("\(#function): \(v)")
        self.volume = v
    }
    
    func getIndex() -> Int? {
        guard playlist.size() > 0 else { return nil }        
        return state.currentIndex
    }
    
    func metadata(for index: Int) -> TrackMetadata {
        let asset = self.asset(for: index)
        let m = TrackMetadata()
        m.loadOnlyText(from: asset)
        return m
    }
    
    func trackInfo(for index: Int) -> TrackListInfo {
        let m = self.metadata(for: index)
        return (m.artist ?? "artist", title: m.title ?? "title")
    }
    
    func isEmpty() -> Bool {
        return self.playlist.size() == 0
    }
    
    func playFrom(_ index: Int) {
        self.state.from(index)
        self.player?.pause()
        self.play(time: nil)
    }
    
    func playNextTrack() {
        self.storage.removeLastTrack()
        self.state.next()
        play(time: nil)
    }
    
    func playPreviousTrack() {
        self.storage.removeLastTrack()
        guard self.state.currentIndex > 0 else { return }
        self.state.previous()
        play(time: nil)
    }
    
    func mute() {
        self.isMuted = !self.isMuted
    }
    
    func playRandomTrack() {
        self.storage.removeLastTrack()
        // obs: experimenting without zero out image
//        self.metadata(for: self.state.playerIndex).artwork = nil
        self.state.random(upperBound: self.playlist.size())
        self.play(time: nil)
    }
    
    func loopTrack() {
        self.state.isLooping = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func trackCount() -> Int {
        return self.playlist.size()
    }
    
    func getIsLooping() -> Bool{
        return self.state.isLooping
    }
    
    func stopLooping() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.state.isLooping = false
    }
    
    func useCache(playlist: Playlist) -> Error? {
        self.playlist = playlist
        if let error = self.storage.change(folder: playlist.folder) {
            return error
        }
        if let url = self.storage.getLastTrack(),
            let index = self.indexFor(url: url, playlist: playlist) {
            self.state.from(index)
        }
        self.volume = self.storage.getVolumeLevel() ?? self.volume
        return nil
    }
    
    func playOrPause() -> Error? {
        if let error = self.saveState() { return error }
        
        let lastTrack = self.storage.getLastTrack()
        let seekTime = self.storage.seekTime(playlist: self.playlist)
        
        // Attempt to resume previous track
        guard !self.resume(lastTrack, time: seekTime) else {
            self.storage.removeLastTrack()
            return nil
        }
    
        if isPlaying() {
            // Pause since user is already playing a track
            player?.pause()
        } else if playItem != nil {
            // Resume the loaded track
            player?.play()
        } else if !isEmpty() {
            // Start from the beginning
            self.play(time: nil)
        }
        
        return nil
    }
    
    func asset(for index: Int) -> AVURLAsset {
        let track = self.playlist.tracks[index]
        return AVURLAsset(url: track, options: PlayerManager.AssetOptions)
    }
    
    func saveState() -> Error? {
        guard !isEmpty() else { return ErrorEmptyPlaylist() }
        let track = self.playlist.tracks[self.state.currentIndex].absoluteString
        self.state.update(time: self.player?.currentTime(), track: track)
        return storage.save(folder: playlist.folder, state: self.state).error
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
        return playlist.index(of: url)
    }
    
    private func resume(_ url: URL?, time: CMTime?) -> Bool{
        guard let url = url, let index = self.indexFor(url: url, playlist: self.playlist) else {
                return false
        }
        self.state.from(index)
        self.play(time: time)
        return true
    }
    
    func setLastPath(url: URL) {
        if let err = self.storage.setLastPath(url) {
           debug_print("\(err.localizedDescription)")
        }
    }
    
    func urlForCurrentPlaylist() -> URL? {
        return self.storage.resolveLastPath()
    }
    
    // TODO: rename this function to match the use in ViewController.loadDefaults()
    func securityScopedUrlForPlaylist() -> URL? {
        return self.storage.lastPathSecurityScopedUrl()
    }
    
    // resetPlayerState used when changing playlist
    func resetPlayerState() -> Error? {
        self.player?.pause()
        self.state.reset()
        return storage.save(folder: playlist.folder, state: self.state).error
    }
    
    func playTime() -> (currentTime: CMTime?, duration: CMTime?) {
        return (self.playItem?.currentTime(), self.playItem?.asset.duration)
    }
    
    func time(for index: Int) -> CMTime {
        if self.indexFor(url: self.playlist.tracks[index], playlist: self.playlist) == index,
            let currentTime = self.storage.seekTime(playlist: self.playlist) {
            return currentTime
        }
        return CMTime(seconds: 0, preferredTimescale: 1000000000)
    }
    
    func duration(for  index: Int) -> CMTime {
        let track = self.playlist.tracks[index]
        return AVURLAsset(url: track, options: PlayerManager.AssetOptions).duration
    }
    
    // Notifications
    
    @objc func didFinishPlaying(note: NSNotification) {
        guard self.state.isLooping else { return }
        self.play(time: nil)
    }
}
