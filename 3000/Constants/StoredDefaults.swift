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
    
    var data: Dictionary<String, Any>?
    
    init(folder: URL) {
      self.load(folder)
    }
    
    private func load(_ folder: URL) {
        do {
            let playlistData = try Data(contentsOf: folder.appendingPathComponent(StoredDefaults.folderInfo))
            let newDict = try JSONSerialization.jsonObject(with: playlistData, options: []) as?  Dictionary<String, Any>

            // Perserve the volume level if playlist has no default
            let oldVolume = self.getVolumeLevel()
            self.data = newDict
            if var data = self.data {
                if data[StoredDefaults.VolumeLevel] == nil {
                    data.updateValue(oldVolume as Any, forKey: StoredDefaults.VolumeLevel)
                } else {
                    print("XXX: not nil")
                }
            }
        } catch  {
            debug_print("error: \(error)")
        }
    }
    
    
    func save(folder: URL, data: Any) {
        let fileUrl = folder.appendingPathComponent(StoredDefaults.folderInfo)
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data, options: [])
            try serializedData.write(to: fileUrl)
            debug_print("Saved to \(fileUrl)")
        } catch {
            debug_print(error.localizedDescription)
        }
        
        // Reload cached data
//        self.load(folder)
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
            let playback = data[StoredDefaults.PlaybackTimeKey] as? Dictionary<String, Double> else {
                return nil
        }
        
        let seconds = playback[StoredDefaults.SecondsKey]
        let timeScale = CMTimeScale(playback[StoredDefaults.TimeScaleKey]!)
        
        return CMTime(seconds: seconds!, preferredTimescale: timeScale)
    }
}
