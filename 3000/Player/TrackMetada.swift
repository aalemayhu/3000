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
    var duration: CMTime?
    
    var isLoaded: Bool {
        get { return self.loaded }
    }
    
    private var loaded = false

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
        
        self.loaded = useImage
        self.duration = asset.duration
        self.setPlaceholders(asset: asset)
    }
    
    private func setPlaceholders(asset: AVURLAsset) {
        if self.title == nil {
            self.title = asset.url.lastPathComponent
        }
        
        if self.artwork == nil {
            self.artwork = NSImage(named: "Placeholder")
        }
    }
    
    func load(from asset: AVURLAsset) {
        self.use(asset: asset, useImage: true)
    }
    
    func unload() {
        self.loaded = false
        self.artwork = nil
    }
    
    func loadOnlyText(from asset: AVURLAsset) {
        self.use(asset: asset, useImage: false)
    }

    func obsData() -> Data? {
        var contents = "Music\n"
        contents += artist != nil ? "Artist: \(artist!)\n" : ""
        contents += title != nil ? "Title: \(title!)\n" : ""
        contents += albumName != nil ? "Album: \(albumName!)\n" : ""
        return contents.data(using: .utf8)
    }
}
