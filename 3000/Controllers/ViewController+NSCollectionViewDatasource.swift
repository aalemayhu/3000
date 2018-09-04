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
        return self.cachedTracksData.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let collectionViewItem = collectionView.makeItem(withIdentifier: PlayableCollectionViewItemIdentifier, for: indexPath)
        guard let playableItem = collectionViewItem as? PlayableCollectionViewItem else { return collectionViewItem }
        playableItem.trackData = self.cachedTracksData[indexPath.item]
        return collectionViewItem
    }
}
