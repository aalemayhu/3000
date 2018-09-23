//
//  AppDelegate+MenuActions.swift
//  3000
//
//  Created by ccscanf on 12/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

extension AppDelegate {
    @IBAction func openDocument(_ sender: Any) {
        guard let window = NSApplication.shared.windows.first else { return }
        
        let panel = NSOpenPanel()
        if let lastPath = StoredDefaults.getLastPath() {
            panel.directoryURL = lastPath
        } else {
            panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        }
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        // Let the user pick a folder to open
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                let url = panel.url {
                self.menuHandler?.selectedDirectory(folder: url)
                // Save the selected path for easier reuse
                let _ = StoredDefaults.setLastPath(url)
                NotificationCenter.default.post(name: Notification.Name.OpenedFolder, object: nil)
            }
        }
    }
    
    @IBAction func floatOnTopItemPressed(_ sender: NSMenuItem) {
        guard let window = NSApplication.shared.windows.first else { return }
        if window.level == NSWindow.Level.floating {
            window.level = NSWindow.Level.normal
            sender.state = .off
            return
        }
        window.level = NSWindow.Level.floating
        sender.state = .on
    }
    
    @IBAction func didSelectPlay(_ sender: NSMenuItem) {
        debug_print("\(#function)")
        menuHandler?.playOrPause()
        if sender.state == .off {
            sender.state = .on
            sender.title = "Pause"
            return
        }
        sender.title = "Play"
        sender.state = .off
    }
    
    @IBAction func didSelectLoop(_ sender: NSMenuItem) {
        menuHandler?.toggleLoop()
        if sender.state == .off {
            sender.state = .on
            return
        }
        sender.state = .off
    }
    
    @IBAction func didSelectRandom(_ sender: NSMenuItem) {
        menuHandler?.playRandomTrack()
    }
    
    @IBAction func didSelectNext(_ sender: NSMenuItem) {
        menuHandler?.playNextTrack()
    }
    
    @IBAction func didSelectPrevious(_ sender: NSMenuItem) {
        menuHandler?.playPreviousTrack()
    }
    
    @IBAction func didSelectMute(_ sender: NSMenuItem) {
        menuHandler?.mute()
        sender.state = sender.state == .off ? .on : .off
    }
    
    @IBAction func didSelectTracks(_ sender: NSMenuItem) {
        menuHandler?.showTracksView()
    }
    
    @IBAction func didSelectVolumeUp(_ sender: NSMenuItem) {
        menuHandler?.changeVolume(change: 0.01)
    }
    
    @IBAction func didSelectVolumeDown(_ sender: NSMenuItem) {
        menuHandler?.changeVolume(change: -0.01)
    }
}
