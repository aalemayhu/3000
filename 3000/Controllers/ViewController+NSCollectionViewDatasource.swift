//
//  ViewController+NSCollectionViewDatasource.swift
//  3000
//
//  Created by ccscanf on 02/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

extension ViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tracks = self.pm?.tracks(), tracks.count > 0 else {
            debug_print("TODO: Handle this case")
            return 0
        }
        return tracks.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let collectionViewItem = collectionView.makeItem(withIdentifier: PlayableCollectionViewItemIdentifier, for: indexPath)
        guard let playableItem = collectionViewItem as? PlayableCollectionViewItem else { return collectionViewItem }
        
        if playableItem.trackData == nil, let tracks = self.pm?.tracks() {
            let playerItem = AVPlayerItem(url: tracks[indexPath.item])
            playableItem.trackData = TrackMetadata.load(playerItem: playerItem)

        }
        return collectionViewItem
    }
}
