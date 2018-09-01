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
    
    var cache = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        configure()        
        view.layer?.backgroundColor = NSColor.black.cgColor
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
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStart(note:)),
                                               name: NSNotification.Name.StartPlayingItem, object: nil)

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        loadDefaults()
    }
    
    func loadDefaults() {
        if let folder = UserDefaults.standard.url(forKey: StoredDefaults.LastPath) {
            let p = Playlist(folder: folder)
            (NSApp.delegate as? AppDelegate)?.pm = PlayerManager(playlist: p)
            self.loadArtwork()
        } else {
            addInfo()
            debug_print("No cached folder")
        }
    }
    
    override func keyDown(with event: NSEvent) {
        debug_print("\(#function)")
        switch event.characters {
        case " ":
            (NSApp.delegate as? AppDelegate)?.pm?.playOrPause()
        default:
            debug_print("unknown key")
        }
    }
    
    @objc func screenResize() {
        debug_print("\(#function)")
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
        for n in [Notification.Name.OpenedFolder, Notification.Name.PressedPlayTextField,
                  Notification.Name.StartFirstPlaylist,
                  NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                  NSWindow.didResizeNotification,NSNotification.Name.StartPlayingItem] {
                    NotificationCenter.default.removeObserver(self, name: n, object: nil)
        }
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
        // Prevent division by zero
        let minX = max(view.bounds.size.width-ImageSizes.ImageWidth, ImageSizes.ImageWidth)
        let minY = max(view.bounds.size.height-ImageSizes.imageHeight, ImageSizes.imageHeight)
        let x = CGFloat(arc4random() % uint(minX))
        let y = CGFloat(arc4random() % uint(minY))
        
        return NSPoint(x: x, y: y)
    }
    
    @objc func loadArtwork() {
        removeOldArtwork()
        guard let tracks = (NSApp.delegate as? AppDelegate)?.pm?.tracks() else {
            return
        }
        for track in tracks {
            let item = AVPlayerItem(url: track)
            // TODO: cache metadata?
            let playable = TrackMetadata.load(playerItem: item)
            
            var f = CGRect.zero
            f.size.width = ImageSizes.ImageWidth
            f.size.height = ImageSizes.imageHeight
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
    
    func removeOldArtwork() {
        for v in self.view.subviews {
            if let imageView = v as? NSImageView {
                imageView.removeFromSuperview()
                debug_print("Removing old image")
            }
        }
    }

    func addNewImageView(imageView: NSImageView) {
        guard let mainView = self.view as? MainView else {
            return
        }
        
        imageView.setFrameOrigin(randomPosition())
        mainView.addSubview(imageView)
    }
    
    // Directory management
    
    @objc func openedDirectory() {
        guard let delegate = NSApp.delegate as? AppDelegate,
        let selectedFolder = delegate.selectedFolder else {
            return
        }
        (NSApp.delegate as? AppDelegate)?.pm?.resetPlayerState()
        NSApplication.shared.windows.first?.title = "..."
        traverseDirectory(selectedFolder)
    }
    
    func traverseDirectory(_ folder: URL) {
        // TODO: handle duplicated
        // TODO: handle case where no playable files have been found
        // TODO: what happens to nested folders?
        let p = Playlist(folder: folder)
        (NSApp.delegate as? AppDelegate)?.pm? = PlayerManager(playlist: p)
        (NSApp.delegate as? AppDelegate)?.pm?.startPlaylist()
    }
    
    // Notification handlers
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        (NSApp.delegate as? AppDelegate)?.pm?.playNextTrack()
    }
    
    @objc func pressed2PlayTextField(note: NSNotification) {
        textField?.removeFromSuperview()
        guard let delegate = NSApp.delegate as? AppDelegate else {
            return
        }
        delegate.openDocument([])
    }
    
    @objc func playerDidStart(note: NSNotification){
        guard let item = (NSApp.delegate as? AppDelegate)?.pm?.currentTrack() else {
            return
        }
        guard let window = NSApplication.shared.windows.first else { return }
        
        let title = TrackMetadata.load(playerItem: item).title!
        let artist = TrackMetadata.load(playerItem: item).artist!
        let albumName = TrackMetadata.load(playerItem: item).albumName!

        window.title = "🎵 \(title) ᭼ \(artist) ᭼ \(albumName)"
    }
}
