//
//  MenuItemHandler.swift
//  3000
//
//  Created by ccscanf on 17/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

protocol AppDelegateActions {
    // Player actions
    func selectedDirectory(folder: URL)
    func playOrPause()
    func playRandomTrack()
    func playNextTrack()
    func playPreviousTrack()
    func mute()
    func changeVolume(change: Float)
    func showTracksView()
    func toggleLoop()
    // Window related actions
    func applicationDidBecomeActive(_ notification: Notification)
    func applicationDidResignActive(_ notification: Notification)
}
