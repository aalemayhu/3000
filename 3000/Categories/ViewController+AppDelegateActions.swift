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
        pm.playOrPause()
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
        self.updateVolumeLabel()
    }
    
    func selectedDirectory(folder: URL) {
        self.selectedFolder = folder
    }
    
    func showTracksView() {
        guard !isTracksControllerVisible else { return }
        if self.tracksController == nil {
            self.tracksController = TracksController(nibName: NSNib.Name(rawValue: "TracksController"), bundle: Bundle.main)
            self.tracksController?.selectorDelegate = self
        } else {
            self.tracksController?.reloadData()
        }
        self.presentViewControllerAsSheet(self.tracksController!)
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
