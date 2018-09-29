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
        if let url = self.pm.urlForCurrentPlaylist() {
            return url
        }
        let homeUrl = FileManager.default.homeDirectoryForCurrentUser
        return homeUrl.appendingPathComponent("Music")
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
        guard !isTracksViewVisible else { return }
        if self.tracksViewController == nil {
            self.tracksViewController = TracksViewController(selectorDelegate: self)
        }
        // TODO: refactor below
        guard let vc = self.tracksViewController else { return }
        vc.view.frame = self.view.frame
        self.view.animator().addSubview(vc.view)
        self.isTracksViewVisible = true
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
