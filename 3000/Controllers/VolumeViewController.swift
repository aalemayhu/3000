//
//  VolumeViewController.swift
//  3000
//
//  Created by ccscanf on 22/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class VolumeViewController: NSViewController {
    
    var slider: NSSlider?
    var selectorDelegate: VolumeSelectorDelegate?
    
    @objc func sliderValueDidChange(_ sender: Any) {
        guard let currentValue = slider?.doubleValue else { return }
        selectorDelegate?.didSelectVolume(volume: currentValue)
    }
    
    func configure() {    
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let parentFrame = self.view.frame
        let sFrame = NSRect(x: 0, y: 0, width: parentFrame.width-15, height: parentFrame.height-15)
        self.slider = NSSlider(frame: sFrame)
        self.slider?.minValue = 0
        self.slider?.maxValue = 1
        
        if let currentVolume = selectorDelegate?.getCurrentVolume() {
            self.slider?.doubleValue = currentVolume
        }
        
        if let slider = self.slider {
            self.view.addSubview(slider)
            self.view.addCenterConstraint(for: slider)
            slider.target = self
            slider.action = #selector(sliderValueDidChange(_:))
        }
    }
    
    // View
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 125, height: 36))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}
