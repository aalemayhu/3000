//
//  ViewController+AppDelegateActions.swift
//  3000
//
//  Created by ccscanf on 13/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController: AppDelegateActions {
    
    func defaultUrlForNSPanel() -> URL {
        return self.pm.urlForCurrentPlaylist() ?? FileManager.default.homeDirectoryForCurrentUser
    }
    
    func setLastPath(url: URL) {
        self.pm.savePlaylistUrl(url)
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.isActive = true
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        self.isActive = false
    }
        
    func playOrPause() {
        if let error = pm.playOrPause() {
            ErrorDialogs.alert(with: error)
        }
    }
    
    func playRandomTrack() {
        pm.playRandomTrack()
    }
    
    func playNextTrack() {
        pm.playNextTrack()
    }
    
    func playPreviousTrack() {
        pm.playPreviousTrack()
    }
    
    func mute() {
        pm.mute()
    }
    
    func changeVolume(change: Float) {
        pm.changeVolume(change: change)
    }
    
    func showTracksView() {
        // TODO: refactor below
        guard !isTracksControllerVisible else { return }
        self.tracksViewController = self.tracksViewController ?? TracksViewController(selectorDelegate: self)
        guard let tracksViewController = self.tracksViewController else { return }
        tracksViewController.view.frame = self.view.frame
        self.view.animator().addSubview(tracksViewController.view)
        self.isTracksControllerVisible = true
    }
    
    func toggleLoop() {
        if (!pm.getIsLooping()) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            pm.loopTrack()
        } else {
            pm.stopLooping()
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
}
