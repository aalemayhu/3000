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
        guard let tracks = (NSApp.delegate as? AppDelegate)?.pm?.tracks(), tracks.count > 0 else {
            debug_print("TODO: Handle this case")
            return 0
        }
        return tracks.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        print("indexPath: \(indexPath)")
        let collectionViewItem = collectionView.makeItem(withIdentifier: PlayableItemIdentifier, for: indexPath)
        // TODO: use a subclass?
        
        if let tracks = (NSApp.delegate as? AppDelegate)?.pm?.tracks(),
            let playableItem = collectionViewItem as? PlayableItem{
            // TODO: bounds check
            print("\(#function): item=\(indexPath.item)")
            let playerItem = AVPlayerItem(url: tracks[indexPath.item])
            playableItem.configure(playerItem)
        }
        print("subview count = \(collectionViewItem.view.subviews.count)")
        //        print("\(collectionViewItem.collectionView)")
        
        return collectionViewItem
    }
}
