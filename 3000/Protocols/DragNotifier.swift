//
//  DragNotifier.swift
//  3000
//
//  Created by ccscanf on 21/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

protocol DragNotifier {
    func didDragFolder(path: String)
}

extension ViewController: DragNotifier {
    func didDragFolder(path: String) {
        guard let url = URL(string: path) else { return }
        self.setLastPath(url: url)
        self.openedDirectory()
    }
}
