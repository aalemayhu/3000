//
//  self.swift
//  3000
//
//  Created by ccscanf on 08/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

class BlurView: NSView {
    //    https://stackoverflow.com/questions/27509351/how-to-apply-blur-effect-to-nsview-nswindow

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.layer?.masksToBounds = true
        self.layerUsesCoreImageFilters = true
        self.layer?.needsDisplayOnBoundsChange = true
        
        let satFilter = CIFilter(name: "CIColorControls")
        satFilter?.setDefaults()
        satFilter?.setValue(NSNumber(value: 2.0), forKey: "inputSaturation")
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(NSNumber(value: 40.0), forKey: "inputRadius")
        
        self.layer?.backgroundFilters = [satFilter!, blurFilter!]        
        self.layer?.needsDisplay()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
