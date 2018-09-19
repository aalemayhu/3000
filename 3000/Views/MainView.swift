//
//  MainView.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class MainView: NSView {

    override func menu(for event: NSEvent) -> NSMenu? {
        debug_print("\(#function): \(event)")
        return super.menu(for: event)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.black.setFill()
        dirtyRect.fill()
    }
    
    override func updateTrackingAreas() {
        for trackingArea in self.trackingAreas {
            self.removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    // Drag events
    
    func setupDragEvents() {                
        self.registerForDraggedTypes([.fileURL])
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        print("\(#function): \(sender)")
        
        return true
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation()
    }
    
}
