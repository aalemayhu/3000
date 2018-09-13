//
//  ErrorDialogs.swift
//  3000
//
//  Created by ccscanf on 13/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

class ErrorDialogs {
    
    
    public static func alertNoPlayableTracks(folder: URL) {
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.messageText = "No playable tracks in \(folder). Try a different folder with mp3s (CMD+O)"
        alert.runModal()
        alert.alertStyle = .critical
    }
    
    public static func alert(with error: Error) {
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.messageText = error.localizedDescription
        alert.runModal()
        alert.alertStyle = .critical
    }

}
