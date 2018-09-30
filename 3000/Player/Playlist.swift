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
    
    var tracks: [URL] {
        get {
            return self.files
        }
    }
    
    private var name: String
    var folder: URL
    
    private var files = [URL]()

    init(folder: URL) {
        self.folder = folder
        self.name = folder.absoluteString        
        self.files = self.allfiles(from: folder)
    }
    
    init() {
        self.name = "empty playlist"
        self.folder = URL(fileURLWithPath: NSString(string: "~/Music").expandingTildeInPath)
    }
    
    private func isSupported(_ type: String) -> Bool {
        return type.hasSuffix(".mp3") || type.hasSuffix(".m4a")
    }
    
    private func allfiles(from: URL) -> [URL] {
        var all = [URL]()
        do {
            let files = try FileManager.default.contentsOfDirectory(at: from, includingPropertiesForKeys: nil, options: [])
            // Get all of the top level files
            all += files.filter { return self.isSupported($0.lastPathComponent.lowercased()) }
            
            // Get files in all subdirectories
            files.forEach({ (u) in
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: u.relativePath, isDirectory: &isDir), isDir.boolValue {
                    all += allfiles(from: u)
                }
            })
        } catch { debug_print("\(error)")  }
        return all
    }
    
    func size() -> Int {
        return self.files.count
    }
        
    func index(of track: URL) -> Int? {
        return self.files.index(of: track)
    }
}
