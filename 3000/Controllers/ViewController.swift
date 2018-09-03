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

    let PlayableCollectionViewItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PlayableCollectionViewItem")

    // Views
    @IBOutlet weak var randomButton: NSButton!
    @IBOutlet weak var artworkCollectionView: NSCollectionView!
    @IBOutlet weak var loopButton: NSButton!
    @IBOutlet weak var trackInfoLabel: NSTextField!
    
    var cache = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        configure()
    }
    
    func configure () {
        self.configureCollectionView()
        configureButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(openedDirectory),
                                               name: Notification.Name.OpenedFolder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadArtwork),
                                               name: Notification.Name.StartFirstPlaylist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStart(note:)),
                                               name: NSNotification.Name.StartPlayingItem, object: nil)

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        loadDefaults()
    }
    
    func configureButtons() {
        loopButton.target = self
        loopButton.action = #selector(ViewController.pressedLoop)
        
        randomButton.target = self
        randomButton.action = #selector(ViewController.pressedRandomButton)
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
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        for n in [Notification.Name.OpenedFolder,
                  Notification.Name.StartFirstPlaylist,
                  NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                  NSNotification.Name.StartPlayingItem] {
                    NotificationCenter.default.removeObserver(self, name: n, object: nil)
        }
    }
    
    func addInfo() {
//        self.textField = Press2PlayTextField(string: "Play a directory with music")
//        guard let text = self.textField else { return }
//        let origin = NSPoint(x: view.frame.size.width - text.frame.size.width,
//                             y: view.frame.size.height-text.frame.size.height)
//        text.setFrameOrigin(origin)
//        text.isSelectable = false
//        text.autoresizingMask = [NSView.AutoresizingMask.minXMargin, NSView.AutoresizingMask.maxXMargin,
//                                 NSView.AutoresizingMask.minYMargin, NSView.AutoresizingMask.maxYMargin]
//        view.addSubview(text)
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
      self.artworkCollectionView.reloadData()
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
        self.artworkCollectionView.reloadData()
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
    
    @objc func playerDidStart(note: NSNotification){
        guard let item = (NSApp.delegate as? AppDelegate)?.pm?.currentTrack() else {
            return
        }
        
        let title = TrackMetadata.load(playerItem: item).title!
        let artist = TrackMetadata.load(playerItem: item).artist!
        let albumName = TrackMetadata.load(playerItem: item).albumName!

        self.trackInfoLabel.stringValue = "🎵 \(title) ᭼ \(artist) ᭼ \(albumName)"
    }
        
    @objc func pressedRandomButton() {
        guard let pm = (NSApp.delegate as? AppDelegate)?.pm else {
            return
        }
        pm.playRandomTrack()
    }
    
    @objc func pressedLoop() {
        print("\(#function)")
        if (randomButton.state == NSControl.StateValue.on) {
            randomButton.state = NSControl.StateValue.off
        } else {
            randomButton.state = NSControl.StateValue.on
        }
//        randomButton.setNextState()
    }
}
