//
//  LoopButton.swift
//  3000
//
//  Created by ccscanf on 04/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class LoopButton: NSButton {
    
//    var bgColor: NSColor = NSColor.gridColor
    private var drawableTitle: NSString?
    var isLooping: Bool = false

    override func draw(_ dirtyRect: NSRect) {
        // https://stackoverflow.com/questions/39488862/nsbutton-with-round-corners-and-background-color
        let bgColor = isLooping ? NSColor.gridColor : NSColor.clear
        self.layer?.cornerRadius = 4
        self.layer?.masksToBounds = true
        self.layer?.backgroundColor = bgColor.cgColor
        bgColor.setFill()
        dirtyRect.fill()
        
        if drawableTitle == nil {
            self.drawableTitle = NSString(string: self.title)
        }
        drawableTitle?.draw(at: NSPoint(x: 10, y: 4), withAttributes: nil)
    }
}
