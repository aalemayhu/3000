//
//  Playlist.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class Playlist {
    
    var tracks = [URL]()
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
