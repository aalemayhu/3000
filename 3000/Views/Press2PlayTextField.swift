//
//  Press2PlayTextField.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

class Press2PlayTextField: NSTextField {
    override func mouseDown(with event: NSEvent) {
        NotificationCenter.default.post(name: Notification.Name.PressedPlayTextField, object: nil)
    }
}
