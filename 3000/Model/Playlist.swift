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
    
    init() {
        self.name = "empty playlist"
        self.folder = URL(fileURLWithPath: "~/Music")
    }
    
    func loadFiles(_ folder: URL) -> [TrackMetadata] {
        var metadata = [TrackMetadata]()
        // Traverse the directory for audio files
        do {
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
            debug_print("\(AVURLAsset.audiovisualTypes())")
            // Use the supported types from AVURLAsset, there might be a simpler way with flatmap
            self.tracks = files.filter { self.isSupported($0.lastPathComponent.lowercased())}
            for track in tracks {
                let asset = AVURLAsset(url: track, options: PlayerManager.AssetOptions)
                metadata.append(TrackMetadata.load(asset: asset))
            }
        } catch { debug_print("\(error)") }
        return metadata
    }
    
    // WIP: supporting nested folders
//    func loadFiles(_ folder: URL) -> [TrackMetadata] {
//        var metadata = [TrackMetadata]()
//        // Traverse the directory for audio files
//        let tracks = self.allTracks(from: folder)
//        for track in tracks {
//            let asset = AVURLAsset(url: track, options: PlayerManager.AssetOptions)
//            metadata.append(TrackMetadata.load(asset: asset))
//        }
//        return metadata
//    }
    
    private func isSupported(_ type: String) -> Bool {
        return type.hasSuffix(".mp3")
    }
    
    private func allTracks(from: URL) -> [URL] {
        var all = [URL]()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: from, includingPropertiesForKeys: nil, options: [])
            
            // Get all of the top level tracks
            all += files.filter { return self.isSupported($0.lastPathComponent.lowercased()) }
            
            // Get tracks in all subdirectories
            files.forEach({ (u) in
                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: u.absoluteString, isDirectory: &isDir)
                if isDir.boolValue {
                    all += allTracks(from: u)
                }
            })
        } catch { debug_print("\(error)")  }
        
        return all
    }
}
