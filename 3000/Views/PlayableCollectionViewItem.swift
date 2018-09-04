//
//  PlayableItem.swift
//  3000
//
//  Created by ccscanf on 02/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa
import AVFoundation

class PlayableCollectionViewItem: NSCollectionViewItem {
    
    var trackData : TrackMetadata? {
        didSet {
            guard let trackData = trackData else { return }
            setTitle(title: trackData.title)
            setImage(image: trackData.artwork)
        }
    }

    func setTitle(title: String?) {
        guard let title = title else { return }
        self.textField?.stringValue = title
    }
    
    func setImage(image: NSImage?) {
        self.imageView?.image = image
    }
}
