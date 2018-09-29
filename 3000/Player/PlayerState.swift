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
    
    var currentIndex: Int {
        get { return self.index }
    }
    
    private var index: Int = 0
    // TODO: save the previous index?
    private var previousIndex = 0
    
    // TODO: save the value of isLooping
    var isLooping = false

    init() {
        self.lastTrack = ""
        self.volume = PlayerManager.DefaultVolumeValue
    }
    
    init(lastTrack: String, volume: Float, seconds: Double?, timescale: CMTimeScale?) {
        self.lastTrack = lastTrack
        self.volume = volume
        self.seconds = seconds
        self.timescale = timescale
    }
    
    func update(time: CMTime?, track: String) {
         self.seconds = time?.seconds
         self.timescale = time?.timescale
         self.lastTrack = track
    }
    
    func reset() {
        self.index = 0
        self.lastTrack = ""
    }
    
    func next() {
        self.previousIndex = self.index
        self.index += 1
    }
    
    func previous() {
        self.index = self.previousIndex
    }
    
    func random(upperBound: Int) {
        self.previousIndex = self.index
        self.index = Int(arc4random_uniform(UInt32(upperBound)))
    }
    
    func from(_ i: Int) {
        self.previousIndex = self.index
        self.index = i
    }
}
