//
//  NSView+CenterConstraint.swift
//  3000
//
//  Created by ccscanf on 24/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension NSView {
    
    func addCenterConstraint(for v: NSView) {
        let centerX = NSLayoutConstraint(item: v, attribute: .centerX, relatedBy: .equal,
                                         toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: v, attribute: .centerY, relatedBy: .equal,
                                         toItem: self, attribute: .centerY, multiplier: 1, constant: 0)        
        self.addConstraint(centerX)
        self.addConstraint(centerY)
    }
}
