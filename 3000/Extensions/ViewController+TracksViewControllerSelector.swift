//
//  ViewController+TracksSelector.swift
//  3000
//
//  Created by ccscanf on 18/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension ViewController: TracksViewControllerSelector {
    
    func numberOfTracks() -> Int {
        return self.pm.trackCount()
    }
    
    func trackInfo(at index: Int) -> TrackListInfo {
        return self.pm.trackInfo(for: index)
    }
    
    func didSelectTrack(index: Int) {
        self.hideTracksView()
        self.pm.playFrom(index)
    }
}
