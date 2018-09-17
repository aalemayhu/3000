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
    private var tracks = [URL]()
    var name: String
    var folder: URL

    
    init(folder: URL) {
        self.folder = folder
        self.name = folder.absoluteString        
        self.tracks = self.allTracks(from: folder)
    }
    
    init() {
        self.name = "empty playlist"
        self.folder = URL(fileURLWithPath: "~/Music")
    }
    
    private func isSupported(_ type: String) -> Bool {
        // TODO: refactor this to use TI / AV types
        return type.hasSuffix(".mp3") || type.hasSuffix(".m4a")
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
