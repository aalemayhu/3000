//
//  ViewController.swift
//  3000
//
//  Created by Alexander Alemayhu on 26/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa
import AVFoundation
import Foundation

class ViewController: NSViewController {
    
    // Views
    var textField: Press2PlayTextField?
    
    var pm: PlayerManager?
    var cache = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(openedDirectory),
                                               name: Notification.Name.OpenedFolder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pressed2PlayTextField),
                                               name: Notification.Name.PressedPlayTextField, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadArtwork),
                                               name: Notification.Name.StartFirstPlaylist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenResize),
                                               name: NSWindow.didResizeNotification, object: nil)
        addInfo()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
    
    override func keyDown(with event: NSEvent) {
        print("\(#function)")
        switch event.characters {
        case " ":
            self.pm?.playOrPause()
        default:
            print("unknown key")
        }
    }
    
    @objc func screenResize() {
        print("\(#function)")
        let subviews = self.view.subviews
        
        for v in subviews {
            guard let imageView = v as? NSImageView else {
                continue
            }

            imageView.setFrameOrigin(randomPosition())            
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.OpenedFolder, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PressedPlayTextField, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.StartFirstPlaylist, object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func addInfo() {
        self.textField = Press2PlayTextField(string: "Play a directory with music")
        guard let text = self.textField else { return }
        let origin = NSPoint(x: view.frame.size.width - text.frame.size.width,
                             y: view.frame.size.height-text.frame.size.height)
        text.setFrameOrigin(origin)
        text.isSelectable = false
        text.autoresizingMask = [NSView.AutoresizingMask.minXMargin, NSView.AutoresizingMask.maxXMargin,
                                 NSView.AutoresizingMask.minYMargin, NSView.AutoresizingMask.maxYMargin]
        view.addSubview(text)
    }
    
    func randomPosition() -> NSPoint {
        let x = CGFloat(arc4random() % uint(view.bounds.size.width-140))
        let y = CGFloat(arc4random() % uint(view.bounds.size.height-116))
        
        return NSPoint(x: x, y: y)
    }
    
    @objc func loadArtwork() {
        guard let tracks = self.pm?.tracks() else {
            return
        }
        
        for track in tracks {
            let item = AVPlayerItem(url: track)
            let playable = TrackMetadata.load(playerItem: item)
            
            var f = CGRect.zero
            f.size.width = 140
            f.size.height = 116
            let imageView = NSImageView(frame: f)
            // TODO: fallback if no image?
            imageView.image = playable.artwork
            // failed attempt at circular imageviews
            if let layer = imageView.layer {
                layer.cornerRadius = 25
                layer.masksToBounds = true
            }
            addNewImageView(imageView: imageView)
        }
    }
    
    func addNewImageView(imageView: NSImageView) {
        guard let mainView = self.view as? MainView else {
            return
        }
        
        imageView.setFrameOrigin(randomPosition())
        mainView.addSubview(imageView)
        print("Adding image at \(NSStringFromRect(imageView.frame))")
    }
    
    // Directory management
    
    @objc func openedDirectory() {
        guard let delegate = NSApp.delegate as? AppDelegate else {
            return
        }
        traverseDirectory(delegate.folders)
    }
    
    func traverseDirectory(_ root: [URL]) {
        // TODO: handle duplicated
        // TODO: handle case where no playable files have been found
        
        // Traverse the directory for audio files
        for folder in root {
            let p = Playlist(name: folder.absoluteString)
            
            do {
                let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
                print(AVURLAsset.audiovisualTypes())
                // Use the supported types from AVURLAsset, there might be a simpler way with flatmap
                p.tracks = files.filter { self.isSupported($0.lastPathComponent.lowercased())}
            } catch {
                continue
            }
            // TODO: what happens to nested folders?
            self.pm = PlayerManager(playlist: p)
            break
        }
        
        self.pm?.startPlaylist()
    }
    
    func isSupported(_ type: String) -> Bool {
        return type.hasSuffix(".mp3") || type.hasSuffix(".wav")
    }
    
    // Notification handlers
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pm?.playNextTrack()
    }
    
    @objc func pressed2PlayTextField(note: NSNotification) {
        textField?.removeFromSuperview()
        guard let delegate = NSApp.delegate as? AppDelegate else {
            return
        }
        delegate.openDocument([])
    }
}
