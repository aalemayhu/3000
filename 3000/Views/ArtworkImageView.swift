//
//  ArtworkImageView

import Foundation
import Cocoa

class ArtworkImageView: DropView {
    
    var image: NSImage?
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.image?.draw(in: dirtyRect)
    }
}
