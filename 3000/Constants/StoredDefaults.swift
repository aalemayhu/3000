//
//  StoredDefaults.swift
//  3000
//
//  Created by Alexander Alemayhu on 28/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import AVFoundation

class StoredDefaults {
    
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
    private var resolvedUrl: URL?
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
            let playlistData = try Data(contentsOf: folder.appendingPathComponent(StoredDefaults.folderInfo))
            let newDict = try JSONSerialization.jsonObject(with: playlistData, options: []) as?  Dictionary<String, Any>
            
            // Perserve the volume level if playlist has no default
            let oldVolume = self.getVolumeLevel()
            self.data = newDict
            if var data = self.data, data[StoredDefaults.VolumeLevel] == nil {
                data.updateValue(oldVolume as Any, forKey: StoredDefaults.VolumeLevel)
            }
        } catch  { return error }
        
        return nil
    }
    
    
    func save(folder: URL, data: Any) -> (Bool, error: Error?) {
        debug_print("\(#function): folder=\(folder) data=\(data)")
        let fileUrl = folder.appendingPathComponent(StoredDefaults.folderInfo)
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data, options: [])
            try serializedData.write(to: fileUrl)
            debug_print("Saved to \(fileUrl)")
        } catch { return (false, error) }
        return (true, nil)
    }
    
    func getLastTrack() -> URL? {
        guard let data = self.data,
            let value = data[StoredDefaults.LastTrackKey] as? String else {
                return nil
        }
        return URL(string: value)
    }
    
    func removeLastTrack() {
        guard var data = self.data else { return }
        data.removeValue(forKey: StoredDefaults.LastTrackKey)
        self.data = data        
    }
    
    func getVolumeLevel() -> Float? {
        guard let data = self.data, let v = data[StoredDefaults.VolumeLevel] else { return nil }
        return (v as AnyObject).floatValue
    }
    
    func seekTime(playlist: Playlist) -> CMTime? {
        guard let data = self.data,
            let playback = data[StoredDefaults.PlaybackTimeKey] as? Dictionary<String, Double>,
            let s = playback[StoredDefaults.TimeScaleKey] else {
                return nil
        }
        
        let seconds = playback[StoredDefaults.SecondsKey]
        let timeScale = CMTimeScale(s)
        
        return CMTime(seconds: seconds!, preferredTimescale: timeScale)
    }
    
    func resolveLastPath() -> URL? {
        do {
            let folder = URL(fileURLWithPath: NSHomeDirectory())
            let fileUrl = folder.appendingPathComponent(StoredDefaults.folderInfo)
            let data = try Data(contentsOf: fileUrl)
            //     public init(resolvingBookmarkData data: Data, options: URL.BookmarkResolutionOptions = default, relativeTo url: URL? = default, bookmarkDataIsStale: inout Bool) throws
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
        
        if let resolvedUrl = self.resolvedUrl{
            let _ = resolvedUrl.startAccessingSecurityScopedResource()
            accessCount += 1

        }
        
        guard let resolvedUrl = resolveLastPath() else { return nil}
        let _ = resolvedUrl.startAccessingSecurityScopedResource()
        accessCount += 1
        return resolvedUrl
    }
    
    func setLastPath(_ url: URL) -> Error? {
        if let resolvedUrl = resolveLastPath() {
            repeat {
                debug_print("\(resolvedUrl.absoluteString).stopAccessingSecurityScopedResource")
//                resolvedUrl.stopAccessingSecurityScopedResource()
                accessCount -= 1
            } while(accessCount > 0)
        }
        
        let folder = URL(fileURLWithPath: NSHomeDirectory())
        let fileUrl = folder.appendingPathComponent(StoredDefaults.folderInfo)
        do {
            let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            try data.write(to: fileUrl)
        } catch {
            return error }
        return nil
    }
}
