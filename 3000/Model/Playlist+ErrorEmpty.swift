//
//  ErrorEmptyPlaylist.swift
//  3000
//
//  Created by ccscanf on 18/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class ErrorEmptyPlaylist: NSError {
    
    init() {
        super.init(domain: "test", code: 0, userInfo: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var localizedDescription: String {
        get {
            return "No playable track, please select a folder"
        }
    }
}
