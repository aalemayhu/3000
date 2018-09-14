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
    
    // TODO: should this be private
    var metadata = [TrackMetadata]()
    private var tracks = [URL]()
    var name: String
    var folder: URL

    
    init(folder: URL) {
        self.folder = folder
        self.name = folder.absoluteString        
        self.metadata = self.loadFiles(folder)
    }
    
    init() {
        self.name = "empty playlist"
        self.folder = URL(fileURLWithPath: "~/Music")
    }
    
    func loadFiles(_ folder: URL) -> [TrackMetadata] {
        debug_print("Loading tracks from: \(folder)")
        var metadata = [TrackMetadata]()
        // Traverse the directory for audio files
        let tracks = self.allTracks(from: folder)
        for track in tracks {
            let asset = AVURLAsset(url: track, options: PlayerManager.AssetOptions)
            metadata.append(TrackMetadata.use(asset: asset))
        }
        self.tracks = tracks
        return metadata
    }
    
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
                if FileManager.default.fileExists(atPath: u.relativePath, isDirectory: &isDir), isDir.boolValue {
                    all += allTracks(from: u)
                }
            })
        } catch { debug_print("\(error)")  }
        return all
    }
    
    func size() -> Int {
        return self.tracks.count
    }
    
    func track(at index: Int) -> URL {
        return self.tracks[index]
    }
    
    func contains(track: URL) -> Bool {
        return self.tracks.contains(track)
    }
    
    func index(of track: URL) -> Int? {
        return self.tracks.index(of: track)
    }
}
