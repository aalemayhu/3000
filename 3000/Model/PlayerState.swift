//
//  PlayerState.swift
//  3000
//
//  Created by ccscanf on 13/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import AVFoundation

class PlayerState {
    
    var lastTrack: String
    var volume: Float
    var seconds: Double?
    var timescale: CMTimeScale?
    var playerIndex = 0
    
    init() {
        self.lastTrack = ""
        self.volume = 0.3
    }
    
    init(lastTrack: String, volume: Float, seconds: Double?, timescale: CMTimeScale?) {
        self.lastTrack = lastTrack
        self.volume = volume
        self.seconds = seconds
        self.timescale = timescale
    }
    
    func jsonData() -> Any {
        var data: [String: Any?] = [
            StoredDefaults.LastTrackKey: self.lastTrack,
            StoredDefaults.VolumeLevel: self.volume
        ]
        // Save the player time
        if let seconds = self.seconds,
            let timescale = self.timescale {
            data[StoredDefaults.PlaybackTimeKey] = [
                StoredDefaults.SecondsKey: seconds,
                StoredDefaults.TimeScaleKey: timescale
            ]
        }
        
        return data
    }
    
    func update(time: CMTime?, track: String) {
         self.seconds = time?.seconds
         self.timescale = time?.timescale
         self.lastTrack = track
    }
    
    func reset() {
        self.playerIndex = 0
        self.lastTrack = ""
    }
}
