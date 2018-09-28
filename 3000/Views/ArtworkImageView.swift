//
//  ArtworkImageView

import Foundation
import Cocoa

class ArtworkImageView: DropView {
    
    private var image: NSImage?
    private let minimumArtworkSize = NSSize(width: 250, height: 250)

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.image?.draw(in: dirtyRect)
    }
    
    func configure(with image: NSImage?) {
        self.image = image
        self.invalidateIntrinsicContentSize()
        self.needsDisplay = true
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
}
