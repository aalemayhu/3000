//
//  DropView.swift
//  3000
//
//  Created by ccscanf on 21/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class DropView: NSView {

    var dragNotifier: DragNotifier?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    // Drag events
    
    func setupDragEvents(dragNotifier: DragNotifier) {
        self.dragNotifier = dragNotifier
        self.registerForDraggedTypes([.fileURL])
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        if let path = pboard.propertyList(forType: .fileURL) as? String {
            self.dragNotifier?.didDragFolder(path: path)
        }
        return true
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        
        guard let types = pboard.types else { return NSDragOperation() }
        
        if (types.contains(.fileURL)) {
            return .copy
        }
        
        return NSDragOperation()
    }    
}
