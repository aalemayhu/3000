//
//  ImageLoader.swift
//  3000
//
//  Created by ccscanf on 14/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

class MetadataLoader: Operation {
    
    // TODO: load all fields here
    var asset: AVURLAsset
    var track: TrackMetadata
    
    init(asset: AVURLAsset, track: TrackMetadata) {
        self.asset = asset
        self.track = track
        super.init()
    }
    
    override func main() {
        track.load(from: self.asset)
    }
}
