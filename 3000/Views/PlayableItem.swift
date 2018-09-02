//
//  PlayableItem.swift
//  3000
//
//  Created by ccscanf on 02/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa
import AVFoundation

class PlayableItem: NSCollectionViewItem {

    func setTitle(title: String?) {
        guard let title = title else { return }
        if let textField = self.textField {
            textField.stringValue = title
        } else {
            let textField = NSTextField(string: title)
            textField.setFrameOrigin(NSPoint(x: textField.frame.origin.x, y: textField.frame.size.height * 0.2))
            textField.isEditable = false
            print("Frame \(NSStringFromRect(textField.frame))")
            self.view.addSubview(textField)
        }
    }
    
    func setImage(image: NSImage?) {
        if let imageView = self.imageView {
            imageView.image = image
        } else {
            let imageView = self.imageView(for: image)
            self.view.addSubview(imageView)
            self.imageView = imageView
        }
    }
    
    func configure(_ playerItem: AVPlayerItem) {
        let playable = TrackMetadata.load(playerItem: playerItem)
        setTitle(title: playable.title)
        setImage(image: playable.artwork)
    }
    
    private func imageView(for artwork: NSImage?) -> NSImageView {
        var f = CGRect.zero
        f.size.width = ImageSizes.ImageWidth
        f.size.height = ImageSizes.imageHeight
        let imageView = NSImageView(frame: f)
        // TODO: fallback if no image?
        imageView.image = artwork
        
        // failed attempt at circular imageviews
        if let layer = imageView.layer {
            layer.cornerRadius = 25
            layer.masksToBounds = true
        }
        return imageView
    }
}
