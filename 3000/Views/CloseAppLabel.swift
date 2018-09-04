//
//  CloseAppLabel.swift
//  3000
//
//  Created by Alexander Alemayhu on 04/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class CloseAppLabel: NSTextField {  
    override func mouseDown(with event: NSEvent) {
        NSApp.terminate(self)
    }
}
