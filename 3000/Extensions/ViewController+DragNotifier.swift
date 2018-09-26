//
//  ViewController+DragNotifier.swift
//  3000
//
//  Created by ccscanf on 21/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

extension ViewController: DragNotifier {
    func didDragFolder(path: String) {
        self.openedDirectory()
    }
}
