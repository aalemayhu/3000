//    https://stackoverflow.com/questions/27509351/how-to-apply-blur-effect-to-nsview-nswindow

import Foundation
import Cocoa
import CoreGraphics

class BlurView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.layer?.masksToBounds = true
        self.layerUsesCoreImageFilters = true
        self.layer?.needsDisplayOnBoundsChange = true
        
        guard let satFilter = CIFilter(name: "CIColorControls") else { return }
        satFilter.setDefaults()
        satFilter.setValue(NSNumber(value: 2.0), forKey: "inputSaturation")
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(NSNumber(value: 40.0), forKey: "inputRadius")
        
        let affineClampFilter = CIFilter(name: "CIAffineClamp")
        let xform = CGAffineTransform(scaleX: 2, y: 2)
        affineClampFilter?.setValue(xform, forKey: "inputTransform")

        self.layer?.backgroundFilters = [satFilter, affineClampFilter!,  blurFilter!]
        self.layer?.needsDisplay()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
