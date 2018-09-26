//
//  PlayerConfiguration.swift
//  3000
//
//  Created by Alexander Alemayhu on 28/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

class PlayerConfiguration {
    
    //
    static let LastPath = "LastPath"
    
    // JSON
    static let PlaybackTimeKey = "PlaybackTime"
    static let TimeScaleKey = "timeScale"
    static let SecondsKey = "seconds"
    static let LastTrackKey = "LastTrack"
    static let VolumeLevelKey = "VolumeLevel"
    static let folderInfo = ".3000.json"
    
    private var accessCount = 0
    private var playlistUrl: URL?
    let defaults = UserDefaults.standard
    
    init(folder: URL) {
    }
    
    func save(folder: URL, state: PlayerState) {
        defaults.set(state.lastTrack, forKey: PlayerConfiguration.LastTrackKey)
        defaults.set(state.volume, forKey: PlayerConfiguration.VolumeLevelKey)
        defaults.set(state.seconds, forKey: PlayerConfiguration.SecondsKey)
        defaults.set(state.timescale, forKey: PlayerConfiguration.TimeScaleKey)
        defaults.synchronize()
    }
    
    func getLastTrack() -> URL? {
        guard let value = defaults.string(forKey: PlayerConfiguration.LastTrackKey) else {
                return nil
        }
        return URL(string: value)
    }
    
    func removeLastTrack() {
        defaults.removeObject(forKey: PlayerConfiguration.LastTrackKey)
        defaults.synchronize()
    }
    
    func getVolumeLevel() -> Float? {
        return defaults.float(forKey: PlayerConfiguration.VolumeLevelKey)
    }
    
    func seekTime(playlist: Playlist) -> CMTime? {
        let seconds = defaults.double(forKey: PlayerConfiguration.PlaybackTimeKey)
        let timeScale = CMTimeScale(defaults.integer(forKey: PlayerConfiguration.TimeScaleKey))
        return CMTime(seconds: seconds, preferredTimescale: timeScale)
    }
    
    func resolveLastPath() -> URL? {
        do {
            let folder = URL(fileURLWithPath: NSHomeDirectory())
            let fileUrl = folder.appendingPathComponent(PlayerConfiguration.folderInfo)
            let data = try Data(contentsOf: fileUrl)
            var isStale = false
            let resolvedUrl = try URL(resolvingBookmarkData: data, options: .withSecurityScope,
                                      relativeTo: nil, bookmarkDataIsStale: &isStale)
            // TODO: handle isStale
            return resolvedUrl
        } catch  {
            debug_print(error.localizedDescription)
            return nil
        }
    }
    
    func lastPathSecurityScopedUrl() -> URL? {
        if self.playlistUrl != nil{
            return self.playlistUrl
        }
        self.playlistUrl = resolveLastPath()
        let _ = self.playlistUrl?.startAccessingSecurityScopedResource()
        accessCount += 1
        return self.playlistUrl
    }
    
    func cleanupScopedResources() {
        guard let resolvedUrl = self.playlistUrl else {
            return
        }
        
        for _ in stride(from: 0, to: accessCount, by: 1) {
            debug_print("\(resolvedUrl.absoluteString).stopAccessingSecurityScopedResource")
            resolvedUrl.stopAccessingSecurityScopedResource()
            accessCount -= 1
        }
        self.playlistUrl = nil
    }
    
    func saveBookmark(_ url: URL) -> Error? {
        self.cleanupScopedResources()
        let folder = URL(fileURLWithPath: NSHomeDirectory())
        let fileUrl = folder.appendingPathComponent(PlayerConfiguration.folderInfo)
        do {
            let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            try data.write(to: fileUrl)
        } catch {
            return error
        }
        return nil
    }
}
