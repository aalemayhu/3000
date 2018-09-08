//
//  NSView+Blur.swift
//  3000
//
//  Created by Alexander Alemayhu on 08/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

extension NSView {
//    https://stackoverflow.com/questions/27509351/how-to-apply-blur-effect-to-nsview-nswindow
    func blur() {
        guard let f = NSScreen.main?.frame else { return }
        removeBlurView()

        let blurView = NSView(frame: f)
        blurView.wantsLayer = true
        blurView.layer?.backgroundColor = NSColor.clear.cgColor
        blurView.layer?.masksToBounds = true
        blurView.layerUsesCoreImageFilters = true
        blurView.layer?.needsDisplayOnBoundsChange = true
        
        let satFilter = CIFilter(name: "CIColorControls")
        satFilter?.setDefaults()
        satFilter?.setValue(NSNumber(value: 2.0), forKey: "inputSaturation")
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(NSNumber(value: 40.0), forKey: "inputRadius")
        
        blurView.layer?.backgroundFilters = [satFilter!, blurFilter!]

        self.addSubview(blurView)
        blurView.layer?.needsDisplay()
    }
    
    func unblur()  {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.3
//            self.subviews[0].animator().alphaValue = 0
        }) {
//            self.animator().alphaValue = 1
            self.removeBlurView()
        }
    }
    
    fileprivate func removeBlurView() {
        for v in self.subviews {
            v.removeFromSuperview()
        }
    }
}
