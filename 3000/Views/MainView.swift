//
//  MainView.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class MainView: NSView {

    @IBOutlet weak var imageView: NSImageView!
    override func menu(for event: NSEvent) -> NSMenu? {
        print("\(#function): \(event)")
        return super.menu(for: event)
    }
    
}
