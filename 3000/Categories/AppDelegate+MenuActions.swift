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
    
    
    // Menu items
    
    @IBAction func openDocument(_ sender: Any) {
        guard let window = NSApplication.shared.windows.first else { return }
        
        let panel = NSOpenPanel()
        if let lastPath = UserDefaults.standard.url(forKey: StoredDefaults.LastPath) {
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
                self.selectedFolder = url
                // Save the selected path for easier reuse
                UserDefaults.standard.set(url, forKey: StoredDefaults.LastPath)
                UserDefaults.standard.synchronize()
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
        print("\(#function)")
        pm?.playOrPause()
        if sender.state == .off {
            sender.state = .on
            sender.title = "Pause"
            return
        }
        sender.title = "Play"
        sender.state = .off
    }
    
    @IBAction func didSelectLoop(_ sender: NSMenuItem) {
        guard let vc = NSApplication.shared.windows.first?.contentViewController as? ViewController else { return }
        vc.toggleLoop()
        if sender.state == .off {
            sender.state = .on
            return
        }
        sender.state = .off
    }
    
    @IBAction func didSelectRandom(_ sender: NSMenuItem) {
        self.pm?.playRandomTrack()
    }
    
    @IBAction func didSelectNext(_ sender: NSMenuItem) {
        self.pm?.playNextTrack()
    }
    
    @IBAction func didSelectPrevious(_ sender: NSMenuItem) {
        self.pm?.playPreviousTrack()
    }
    
    @IBAction func didSelectMute(_ sender: NSMenuItem) {
        self.pm?.mute()
    }
    
    @IBAction func didSelectTracks(_ sender: NSMenuItem) {
        guard let vc = NSApplication.shared.windows.first?.contentViewController as? ViewController else { return }
        vc.showTracksView()
    }
    
    @IBAction func didSelectVolumeUp(_ sender: NSMenuItem) {
        guard let vc = NSApplication.shared.windows.first?.contentViewController as? ViewController else { return }
        pm?.changeVolume(change: 0.01)
        vc.updateVolumeLabel()
    }
    
    @IBAction func didSelectVolumeDown(_ sender: NSMenuItem) {
        guard let vc = NSApplication.shared.windows.first?.contentViewController as? ViewController else { return }
        pm?.changeVolume(change: -0.01)
        vc.updateVolumeLabel()
    }
}
