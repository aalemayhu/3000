//
//  Playlist.swift
//  3000
//
//  Created by Alexander Alemayhu on 27/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

class Playlist {
    
    var tracks = [URL]()
    var name: String
    var folder: URL
    
    init(folder: URL) {
        self.folder = folder
        self.name = folder.absoluteString
    }
    
    func loadFiles(_ folder: URL) -> [TrackMetadata] {
        var metadata = [TrackMetadata]()
        // Traverse the directory for audio files
        do {
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
            debug_print("\(AVURLAsset.audiovisualTypes())")
            // Use the supported types from AVURLAsset, there might be a simpler way with flatmap
            self.tracks = files.filter {
                return self.isSupported($0.lastPathComponent.lowercased())                
            }
            
            for track in tracks {
                let asset = AVURLAsset(url: track, options: PlayerManager.AssetOptions)
                let m = TrackMetadata.load(asset: asset)
                metadata.append(m)
            }
        } catch {
            debug_print("CATCH???: \(error)")
        }
        return metadata
    }
    
    private func isSupported(_ type: String) -> Bool {
        return type.hasSuffix(".mp3") || type.hasSuffix(".wav") || type.hasSuffix(".m4a")
    }
}
