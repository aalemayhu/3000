//
//  ViewController+NSWindowDelegate.swift
//  3000
//
//  Created by ccscanf on 28/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension ViewController: NSWindowDelegate {
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        debug_print("\(#function)")
        self.view.animator().isHidden = true
        debug_print("view.frame=\(self.view.frame)")
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        debug_print("\(#function)")
        self.view.animator().isHidden = false
        debug_print("view.frame=\(self.view.frame)")
    }
    
    func window(_ window: NSWindow, startCustomAnimationToEnterFullScreenWithDuration duration: TimeInterval) {
        debug_print("\(#function)")
        guard let screen = window.screen else { return }
        self.sizeBeforeFullscreen = window.frame
        window.backgroundColor = NSColor.black
        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = duration
            window.animator().setFrame(screen.frame, display: true)
        }
    }
    
    func window(_ window: NSWindow, startCustomAnimationToExitFullScreenWithDuration duration: TimeInterval) {
        guard let sizeBeforeFullscreen = self.sizeBeforeFullscreen else { return }
        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = duration
            window.animator().setFrame(sizeBeforeFullscreen, display: true)
        }
    }
    
    func customWindowsToEnterFullScreen(for window: NSWindow) -> [NSWindow]? {
        return [window]
    }
}
