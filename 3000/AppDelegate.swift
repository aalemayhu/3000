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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return nil
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let vc = NSApplication.shared.windows.first?.contentViewController as? ViewController else { return .terminateNow }
        if let error = vc.pm.saveState() {
            debug_print("ERROR: \(error.localizedDescription)")
        }
        return .terminateNow
    }
}

