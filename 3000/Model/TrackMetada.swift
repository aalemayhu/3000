//
//  NowPlaying.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class TrackMetadata {    
    var title: String?
    var type: String?
    var albumName: String?
    var artist: String?
    var artwork: NSImage?
    
    static func load(asset: AVURLAsset) -> TrackMetadata {
        let np = TrackMetadata()
        
        for item in asset.metadata {
            guard let commonKey = item.commonKey, let _ = item.value else {
                debug_print("Failed to read metadata for \(item)")
                continue
            }
            
            switch (commonKey) {
            case AVMetadataKey.commonKeyTitle:
                np.title = item.stringValue
                
            case AVMetadataKey.commonKeyType:
                np.type = item.stringValue
            case AVMetadataKey.commonKeyAlbumName:
                np.albumName = item.stringValue
            case AVMetadataKey.commonKeyArtist:
                np.artist = item.stringValue
            case AVMetadataKey.commonKeyArtwork:
                if let data = item.dataValue, let image = NSImage(data: data) {
                    np.artwork = image
                }
            default:
                debug_print("NO match for \(commonKey)")
                continue
            }
        }
        
        return np
    }
}
