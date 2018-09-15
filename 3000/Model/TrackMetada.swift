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
    // TODO: reduce memory usage
    var artwork: NSImage?
    
    private func use(asset: AVURLAsset, useImage: Bool = false) {
        for item in asset.metadata {
            guard let commonKey = item.commonKey, let _ = item.value else {
                debug_print("Failed to read metadata for \(item)")
                continue
            }
            
            switch (commonKey) {
            case AVMetadataKey.commonKeyTitle:
                self.title = item.stringValue
                
            case AVMetadataKey.commonKeyType:
                self.type = item.stringValue
            case AVMetadataKey.commonKeyAlbumName:
                self.albumName = item.stringValue
            case AVMetadataKey.commonKeyArtist:
                self.artist = item.stringValue
            case AVMetadataKey.commonKeyAuthor where self.artist == nil:
                self.artist = item.stringValue
            case AVMetadataKey.commonKeyArtwork where useImage:
                if let data = item.dataValue, let image = NSImage(data: data) {
                    self.artwork = image
                }
            default:
                debug_print("NO match for \(commonKey)")
                continue
            }
        }
    }
    
    // TODO: for handling loading errors
    func load(from asset: AVURLAsset) {
        self.use(asset: asset, useImage: true)
    }
    
    func loadOnlyText(from asset: AVURLAsset) {
        self.use(asset: asset, useImage: false)
    }
}
