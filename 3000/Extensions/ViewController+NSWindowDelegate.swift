//
//  ViewController+NSWindowDelegate.swift
//  3000
//
//  Created by ccscanf on 28/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension ViewController: NSWindowDelegate {
    
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        debug_print("\(#function)")
        let fontSize = max(self.imageView.frame.size.width/28, 13)
        self.trackArtistLabel.font = NSFont(name: "Helvetica Neue Bold", size: fontSize)
        self.trackInfoLabel.font = NSFont(name: "Helvetica Neue Light", size: fontSize)
        self.imageView.needsLayout = true
        self.view.needsLayout = true
        return frameSize
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        debug_print("\(#function)")
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        debug_print("\(#function)")
    }
    
    func window(_ window: NSWindow, startCustomAnimationToEnterFullScreenWithDuration duration: TimeInterval) {
        debug_print("\(#function)")
//        guard let screen = window.screen else { return }
//        self.sizeBeforeFullscreen = window.frame
//        NSAnimationContext.runAnimationGroup { (context) in
//            context.duration = duration
//            window.animator().setFrame(screen.frame, display: true)
////            window.animator().setContentSize(screen.frame.size)
//        }
    }
    
    func window(_ window: NSWindow, startCustomAnimationToExitFullScreenWithDuration duration: TimeInterval) {
        debug_print("\(#function)")
//        guard let sizeBeforeFullscreen = self.sizeBeforeFullscreen else { return }
//        NSAnimationContext.runAnimationGroup { (context) in
//            context.duration = duration
//            window.animator().setFrame(sizeBeforeFullscreen, display: true)
//        }
    }
    
    func customWindowsToEnterFullScreen(for window: NSWindow) -> [NSWindow]? {
        return [window]
    }
}
