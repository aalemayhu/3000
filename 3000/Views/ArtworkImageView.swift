//
//  ArtworkImageView

import Foundation
import Cocoa

class ArtworkImageView: DropView {
    
    private var image: NSImage?
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.image?.draw(in: dirtyRect)
    }
    
    func configure(with image: NSImage?) {
        self.image = image
        self.needsDisplay = true
    }
}
