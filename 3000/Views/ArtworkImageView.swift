//
//  ArtworkImageView

import Foundation
import Cocoa

class ArtworkImageView: DropView {
    
    private var blurView: BlurView?
    private var imageView: NSImageView?
    private var image: NSImage?
    private let minimumArtworkSize = NSSize(width: 250, height: 250)
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.imageView?.draw(dirtyRect)
    }
    
    func configure(with image: NSImage?) {
        self.image = image
        configureLayer()
        self.invalidateIntrinsicContentSize()
        self.needsDisplay = true
        if self.imageView == nil {
            imageView = NSImageView(frame: self.frame)
            imageView?.unregisterDraggedTypes()
            self.addSubview(imageView!)
        }
        imageView?.image = self.image
    }
    
    private func configureLayer() {
        if self.layer == nil {
            self.layer = CALayer()
        }
        self.wantsLayer = true
        self.layer?.cornerRadius = 4
        self.layer?.masksToBounds = true
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            guard let image = self.image else { return self.minimumArtworkSize }
            // Make sure the artwork size is not too small
            if image.size.width < self.minimumArtworkSize.width ||
                image.size.height < self.minimumArtworkSize.height {
                return self.minimumArtworkSize
            }
            if image.size.width != image.size.height {
                debug_print("Image not quadratic, fallingback on using width for the size")
                return NSSize(width: image.size.width, height: image.size.width)
            }
            return image.size
        }
    }
    
    func resize(frame: NSRect) {
        self.frame = frame
        self.imageView?.frame = frame
        self.blurView?.frame = frame
        self.needsDisplay = true
    }
    
    // Blur management
    
    func blur() {
        if self.blurView == nil {
            guard let f = NSScreen.main?.frame else { return }
            self.blurView = BlurView(frame: f)
        }
        
        if let blurView = self.blurView {
            self.addSubview(blurView)
        }
    }
    
    func unblur()  {
        self.blurView?.removeFromSuperview()
    }
}
