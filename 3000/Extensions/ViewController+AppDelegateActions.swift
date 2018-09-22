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
    
    func selectedDirectory(folder: URL) {
        self.selectedFolder = folder
    }
    
    func showTracksView() {
        guard !isTracksControllerVisible else { return }
        self.tracksViewController = self.tracksViewController ?? TracksViewController(selectorDelegate: self)
        guard let tracksController = self.tracksViewController else { return }
        self.popOverTracks = self.popOver(for: tracksController)
        self.popOverTracks?.show(relativeTo: self.view.bounds, of: self.trackInfoLabel, preferredEdge: .maxY)
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
