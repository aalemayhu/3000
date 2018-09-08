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
    func blur() {
        let v = self.subviews.filter { $0 is BlurView }.count
        if v == 0 {
            guard let f = NSScreen.main?.frame else { return }
            let blurView = BlurView(frame: f)
            self.addSubview(blurView)
        }
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.4
            updateBlurView(alphaValue: 1)
        }) {}
    }
    
    func unblur()  {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.4
            updateBlurView(alphaValue: 0)
        }) {}
    }
    
    fileprivate func updateBlurView(alphaValue: CGFloat) {
        print("\(#function): \(alphaValue)")
        let blurredViews = self.subviews.filter { $0 is BlurView }
        if let blurView = blurredViews[0] as? BlurView {
            
            blurView.animator().alphaValue = alphaValue
            // TODO: - [ ] Fix fade out animation
            if alphaValue == 0  {
                blurView.removeFromSuperview()
            }
        }
    }
}
