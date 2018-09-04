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
    @IBOutlet weak var loopButton: LoopButton!
    @IBOutlet weak var trackInfoLabel: NSTextField!
    @IBOutlet weak var trackArtistLabel: NSTextField!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    var cachedTracksData = [TrackMetadata]()
    var cache = [String: Bool]()
    var pm: PlayerManager?
    
    var timeObserverToken: Any?
    
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
            self.load(folder)
            self.loadArtwork()
        } else {
            debug_print("No cached folder")
        }
    }
    
    override func keyDown(with event: NSEvent) {
        debug_print("\(#function)")
        guard let pm = self.pm else { return }
        switch event.characters {
        case " ":
            pm.playOrPause()
        case "+":
            volumeSlider.doubleValue = volumeSlider.doubleValue + 1
            pm.changeVolume(change: 0.1)
        case "-":
            pm.changeVolume(change: -0.1)
            volumeSlider.doubleValue = volumeSlider.doubleValue - 1
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
    
    func load(_ folder: URL) {                
        let p = Playlist(folder: folder)
        self.pm = PlayerManager(playlist: p)
        self.cachedTracksData = p.loadFiles(folder)

        self.artworkCollectionView.reloadData()

        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.pm = self.pm
        }
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
        // TODO: handle duplicated
        // TODO: handle case where no playable files have been found
        // TODO: what happens to nested folders?        
        self.pm?.resetPlayerState()
        self.load(selectedFolder)
        self.pm?.startPlaylist()
    }
    
    // Notification handlers
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pm?.playNextTrack()
    }
    
    @objc func playerDidStart(note: NSNotification){
        guard let item = self.pm?.currentTrack() else {
            return
        }
        self.addPeriodicTimeObserver()
        let title = TrackMetadata.load(playerItem: item).title!
        let artist = TrackMetadata.load(playerItem: item).artist!
        let albumName = TrackMetadata.load(playerItem: item).albumName!

        self.trackInfoLabel.stringValue = "🎵 \(title) ᭼ \(albumName)"
        self.trackArtistLabel.stringValue = "\(artist)"
    }
        
    @objc func pressedRandomButton() {
        guard let pm = self.pm else { return }
        pm.playRandomTrack()
    }
    
    @objc func pressedLoop() {
        guard let pm = self.pm else { return }
        if (!pm.getIsLooping()) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            pm.loopTrack()
        } else {
            pm.stopLooping()
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    // Control events
    
    @IBAction func sliderDidChange(_ sender: NSSlider) {
        guard let pm = self.pm else { return }
        var volume = volumeSlider.doubleValue
        if (volume > 0) {
            volume = volume / 10
        }
        pm.setVolume(volume: Float(volume))
    }
    
    // Player observers
    
    func playerTimeProgressed() {
        guard let pm = self.pm, let player = pm.player,
        let currentItem = player.currentItem else { return }

        let currentTime = currentItem.currentTime()
        let duration = currentItem.duration
        
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        let durationInSeconds = CMTimeGetSeconds(duration)
        print("\(#function): \(currentTimeInSeconds) / \(durationInSeconds)")
    }
    
    func addPeriodicTimeObserver() {
        guard let pm = self.pm, let player = pm.player else { return }
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) {
                                                            [weak self] time in
                                                            self?.playerTimeProgressed()
        }
    }
    
    func removePeriodicTimeObserver() {
        guard let pm = self.pm, let player = pm.player else { return }
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}
