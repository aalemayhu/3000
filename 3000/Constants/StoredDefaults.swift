//
//  StoredDefaults.swift
//  3000
//
//  Created by Alexander Alemayhu on 28/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class StoredDefaults {
    // TODO: move these from defaults to json
    static let LastPath = "LastPath"
    static let LastTrack = "LastTrack"
    
    // JSON
    static let PlaybackTimeKey = "PlaybackTime"
    static let TimeScaleKey = "timeScale"
    static let SecondsKey = "seconds"
    
    
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
}
