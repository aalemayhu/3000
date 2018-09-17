//
//  TracksController.swift
//  3000
//
//  Created by ccscanf on 11/09/2018.
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

class TracksController: NSViewController {
    
    var selectorDelegate: TracksControllerSelector?
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    func configure() {
        self.tableView.delegate = self
        self.tableView.dataSource = self        
        self.reloadData()
    }
    
    func reloadData() {
        self.tableView.reloadData()
        if let image = selectorDelegate?.currentArtwork() {
            self.imageView.image = image
        }
    }
}
