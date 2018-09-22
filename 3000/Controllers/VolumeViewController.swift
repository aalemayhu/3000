//
//  VolumeViewController.swift
//  3000
//
//  Created by ccscanf on 22/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class VolumeViewController: NSViewController {

    @IBOutlet weak var slider: NSSlider!
    
    var selectorDelegate: VolumeSelectorDelegate?
    
    init(selectorDelegate: VolumeSelectorDelegate) {
        super.init(nibName: "VolumeViewController", bundle: Bundle.main)
        self.selectorDelegate = selectorDelegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func sliderValueDidChange(_ sender: Any) {
        let currentValue = slider.doubleValue
        selectorDelegate?.didSelectVolume(volume: currentValue)
    }
    
    // View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.slider.minValue = 0
        self.slider.maxValue = 1
        
        if let currentVolume = selectorDelegate?.getCurrentVolume() {
            self.slider.doubleValue = currentVolume
        }        
    }
}
