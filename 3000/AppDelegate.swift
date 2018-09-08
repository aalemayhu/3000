//
//  AppDelegate.swift
//  3000
//
//  Created by Alexander Alemayhu on 26/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var selectedFolder: URL?
    
    // TODO: get pm out of here
    var pm: PlayerManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
//        NSApplication.shared.windows.first?.styleMask = NSWindow.StyleMask.borderless
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return nil
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        self.pm?.saveState()
        return .terminateNow
    }

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
}

