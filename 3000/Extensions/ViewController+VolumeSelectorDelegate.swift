//
//  ViewController+VolumeSelectorDelegate.swift
//  3000
//
//  Created by ccscanf on 22/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension ViewController: VolumeSelectorDelegate {
    func getCurrentVolume() -> Double {
        return Double(self.pm.getVolume())
    }
    
    func didSelectVolume(volume: Double) {
        self.pm.setVolume(v: Float(volume))
    }
}
