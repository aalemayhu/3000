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
    
    
    static func save(folder: URL, data: Any) {
        let fileUrl = folder.appendingPathComponent(".3000.json")        
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data, options: [])
            try serializedData.write(to: fileUrl)
            print("Saved to \(fileUrl)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func presisted(folder: URL) -> Dictionary<String, Any>? {
        do {
            let data = try Data(contentsOf: folder.appendingPathComponent(".3000.json"))
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as?  Dictionary<String, Any>
            return dict
        } catch  {
            print("error: \(error)")
        }
        
        return nil
    }
    
    static func getLastTrack(playlist: Playlist) -> URL? {
        guard let persisted = StoredDefaults.presisted(folder: playlist.folder) else {
            return nil
        }
        
        if let value = persisted[LastTrackKey] as? String {
            return URL(string: value)
        }
        
        return nil
    }
    
    static func seekTime(playlist: Playlist) -> CMTime? {
        guard let persisted = StoredDefaults.presisted(folder: playlist.folder),
            let playback = persisted[StoredDefaults.PlaybackTimeKey] as? Dictionary<String, Double> else {
                return nil
        }
        
        let seconds = playback[StoredDefaults.SecondsKey]
        let timeScale = CMTimeScale(playback[StoredDefaults.TimeScaleKey]!)
        
        return CMTime(seconds: seconds!, preferredTimescale: timeScale)
    }
}
