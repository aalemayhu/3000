//
//  PlayerConfiguration.swift
//  3000
//
//  Created by Alexander Alemayhu on 28/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

// TODO: rename to player configuration
class PlayerConfiguration {
    
    //
    static let LastPath = "LastPath"
    
    // JSON
    static let PlaybackTimeKey = "PlaybackTime"
    static let TimeScaleKey = "timeScale"
    static let SecondsKey = "seconds"
    static let LastTrackKey = "LastTrack"
    static let VolumeLevel = "VolumeLevel"
    static let folderInfo = ".3000.json"
    
    private var accessCount = 0
    private var playlistUrl: URL?
    var data: Dictionary<String, Any>?
    
    init(folder: URL) {
        self.use(folder: folder)
    }
    
    private func use(folder: URL) {
        if let error = change(folder: folder) {
            debug_print("\(error.localizedDescription)")
        }
    }
    
    func change(folder: URL) -> Error?{
        do {
            let playlistData = try Data(contentsOf: folder.appendingPathComponent(PlayerConfiguration.folderInfo))
            let newDict = try JSONSerialization.jsonObject(with: playlistData, options: []) as?  Dictionary<String, Any>
            
            // Perserve the volume level if playlist has no default
            let oldVolume = self.getVolumeLevel()
            self.data = newDict
            if var data = self.data, data[PlayerConfiguration.VolumeLevel] == nil {
                data.updateValue(oldVolume as Any, forKey: PlayerConfiguration.VolumeLevel)
            }
        } catch  { return error }
        
        return nil
    }
    
    
    func save(folder: URL, state: PlayerState) -> (Bool, error: Error?) {
        let data = self.jsonData(state: state)
        let fileUrl = folder.appendingPathComponent(PlayerConfiguration.folderInfo)
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data, options: [])
            try serializedData.write(to: fileUrl)
            debug_print("Saved to \(fileUrl)")
        } catch { return (false, error) }
        return (true, nil)
    }
    
    private func jsonData(state: PlayerState) -> Any {
        var data: [String: Any?] = [
            PlayerConfiguration.LastTrackKey: state.lastTrack,
            PlayerConfiguration.VolumeLevel: state.volume
        ]
        // Save the player time
        if let seconds = state.seconds,
            let timescale = state.timescale {
            data[PlayerConfiguration.PlaybackTimeKey] = [
                PlayerConfiguration.SecondsKey: seconds,
                PlayerConfiguration.TimeScaleKey: timescale
            ]
        }
        
        return data
    }
    
    
    func getLastTrack() -> URL? {
        guard let data = self.data,
            let value = data[PlayerConfiguration.LastTrackKey] as? String else {
                return nil
        }
        return URL(string: value)
    }
    
    func removeLastTrack() {
        guard var data = self.data else { return }
        data.removeValue(forKey: PlayerConfiguration.LastTrackKey)
        self.data = data        
    }
    
    func getVolumeLevel() -> Float? {
        guard let data = self.data, let v = data[PlayerConfiguration.VolumeLevel] else { return nil }
        return (v as AnyObject).floatValue
    }
    
    func seekTime(playlist: Playlist) -> CMTime? {
        guard let data = self.data,
            let playback = data[PlayerConfiguration.PlaybackTimeKey] as? Dictionary<String, Double>,
            let s = playback[PlayerConfiguration.TimeScaleKey] else {
                return nil
        }
        
        let seconds = playback[PlayerConfiguration.SecondsKey]
        let timeScale = CMTimeScale(s)
        
        return CMTime(seconds: seconds!, preferredTimescale: timeScale)
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
    
    func setLastPath(_ url: URL) -> Error? {
        self.cleanupScopedResources()
        
        let folder = URL(fileURLWithPath: NSHomeDirectory())
        let fileUrl = folder.appendingPathComponent(PlayerConfiguration.folderInfo)
        do {
            let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            try data.write(to: fileUrl)
        } catch {
            return error }
        return nil
    }
}
