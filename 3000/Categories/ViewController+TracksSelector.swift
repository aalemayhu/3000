//
//  ViewController+TracksSelector.swift
//  3000
//
//  Created by ccscanf on 18/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension ViewController: TracksControllerSelector {
    
    func numberOfTracks() -> Int {
        return self.pm.trackCount()
    }
    
    func currentArtwork() -> NSImage? {
        return self.imageView?.layer?.contents as? NSImage
    }
    
    func trackInfo(at index: Int) -> TrackListInfo {
        return self.pm.trackInfo(for: index)
    }
    
    func didSelectTrack(index: Int) {
        self.isTracksControllerVisible = false
        self.pm.playFrom(index)
    }
}
