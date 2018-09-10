//
//  LayeredBackedImageView.swift
// https://stackoverflow.com/questions/23002653/nsimageview-image-aspect-fill

import Foundation
import Cocoa

class LayeredBackedImageView: NSView {
    
    init(frame frameRect: NSRect, andImage image: NSImage) {
        super.init(frame: frameRect)
        self.layer = CALayer()
        self.layer?.contentsGravity = kCAGravityResizeAspectFill
        self.layer?.contents = image
        self.wantsLayer = true
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}
