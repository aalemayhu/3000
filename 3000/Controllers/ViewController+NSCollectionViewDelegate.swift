//
//  ViewController+NSCollectionViewDelegate.swift
//  3000
//
//  Created by ccscanf on 02/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        debug_print("\(#function)")
        guard let pm = (NSApp.delegate as? AppDelegate)?.pm,
        let indexPath = indexPaths.first else {
            return
        }
        pm.playFrom(indexPath.item)
    }
}
