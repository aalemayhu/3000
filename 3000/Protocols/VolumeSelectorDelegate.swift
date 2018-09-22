//
//  VolumeSelectorDelegate.swift
//  3000
//
//  Created by ccscanf on 22/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

protocol VolumeSelectorDelegate {
    func didSelectVolume(volume: Double)
    func getCurrentVolume() -> Double
}
