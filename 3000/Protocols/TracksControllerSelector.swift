//
//  TracksControllerSelector.swift
//  3000
//
//  Created by ccscanf on 18/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

typealias TrackListInfo = (artist: String, title: String)

protocol TracksControllerSelector {
    func didSelectTrack(index: Int)
    func trackInfo(at index: Int) -> TrackListInfo
    func numberOfTracks() -> Int
    func currentArtwork() -> NSImage?
}
