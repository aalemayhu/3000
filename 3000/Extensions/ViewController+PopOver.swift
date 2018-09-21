//
//  ViewController+PopOver.swift
//  3000
//
//  Created by ccscanf on 18/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension ViewController: NSPopoverDelegate {
    
    func popoverShouldClose(_ popover: NSPopover) -> Bool {
        return !self.isTracksControllerVisible
    }
}
