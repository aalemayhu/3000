//
//  ArtworkImageView

import Foundation
import Cocoa

class ArtworkImageView: NSImageView {
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    // Drag events
    
    func setupDragEvents() {
        self.registerForDraggedTypes([.fileURL])
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let items = sender.draggingPasteboard().pasteboardItems else { return false }
        for item in items {
            print("\(#function): \(item)")
        }
        
        return true
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
}
