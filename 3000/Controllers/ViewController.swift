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
import Dispatch

class ViewController: NSViewController {
    
    // TODO: reduce memory usage in this class
    
    let PlayableCollectionViewItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PlayableCollectionViewItem")
    
    // Views
    @IBOutlet weak var trackInfoLabel: NSTextField!
    @IBOutlet weak var trackArtistLabel: NSTextField!
    @IBOutlet weak var imageView: ArtworkImageView!
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var progressSlider: NSSlider!
//    @IBOutlet weak var volumeLabel: NSTextField!
    
    @IBOutlet weak var volumeButton: NSButton!
    
    var cache = [String: Bool]()
    var pm: PlayerManager = PlayerManager()
    var selectedFolder: URL?
    
    var timeObserverToken: Any?
    var tracksViewController: TracksViewController?
    var volumeViewController: VolumeViewController?
    
    // TODO: rename to be more popover specific
    var isTracksControllerVisible = false
    var isVolumeViewControllerVisible = false

    var popOverVolume: NSPopover?
    var popOverTracks: NSPopover?

    var isActive = true
    
    var mainView: MainView? {
        get {
            return self.view as? MainView
        }
    }
    
    // View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.aspectRatio = NSSize(width: 1, height: 1)
    }
    
    // View changes
    
    @objc func updateView() {
        guard let index = pm.getIndex() else {
            self.updateViewForEmptyPlaylist()
            return
        }
        
        let track = self.pm.metadata(for: index)
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        // Album image
        loadArtwork(for: index, track: track)
        
        // Track info
        let textColor = track.artwork?.areaAverage().contrast()
        self.trackInfoLabel.stringValue = "\(title)"
        self.trackArtistLabel.stringValue = "\(artist)"
        self.trackInfoLabel.textColor = textColor
        self.trackArtistLabel.textColor = textColor
        
        self.updateTimeElements(for: index)
    }
    
    func updateViewForEmptyPlaylist() {
        self.currentTimeLabel.stringValue = ""
        self.durationLabel.stringValue = ""
        self.trackInfoLabel.stringValue = ""
        self.trackArtistLabel.stringValue = "Press space 2 play or CMD+O"
        
        if let path = Bundle.main.path(forResource: "placeholder", ofType: ".png") {
            self.imageView.configure(with: NSImage(contentsOfFile: path))
        }
    }
    
    func updateTimeElements(for index: Int) {
        debug_print("\(#function)")
        // Either use the playing items duration or load from currently not playing item
        let playTime = pm.playTime()
        
        let duration = playTime.duration ?? pm.duration(for: index)
        let currentTime = playTime.currentTime ?? pm.time(for: index)
        
        self.setupProgressSlider(duration)
        self.updatePlayTimeLabels(currentTime, duration)
    }
    
    func updateArtwork(with artwork: NSImage?) {
        guard let artwork = artwork else { return }
        self.imageView.configure(with: artwork)
    }
    
    func loadArtwork(for index: Int, track: TrackMetadata) {
        let op = MetadataLoader(asset: self.pm.asset(for: index), track: track, completionBlock: {
            DispatchQueue.main.sync {
                self.updateArtwork(with: track.artwork)
            }
        })
        op.start()
    }
    
    @objc func screenResize() {
        let fontSize = max(self.imageView.frame.size.width/28, 13)
        self.trackArtistLabel.font = NSFont(name: "Helvetica Neue Bold", size: fontSize)
        self.trackInfoLabel.font = NSFont(name: "Helvetica Neue Light", size: fontSize)
        
        self.currentTimeLabel.font = NSFont(name: "Helvetica Neue", size: fontSize)
        self.durationLabel.font = NSFont(name: "Helvetica Neue", size: fontSize)
    }
    
    @IBAction func volumeButtonPressed(_ sender: NSButton) {
        self.showVolumeView()
    }
    // ---
    
    func configure () {
        registerNotificationObservers()
        registerLocalMonitoringKeyboardEvents()
        
        loadDefaults()
        progressSlider.trackFillColor = NSColor.gray
        
        toggleTrackInfo(hidden: true)
        
        self.mainView?.setupDragEvents(dragNotifier: self)
        self.imageView?.setupDragEvents(dragNotifier: self)
    }
    
    func registerLocalMonitoringKeyboardEvents() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            // Only use supported keybindings
            if let key = $0.characters, let k = Keybinding(rawValue: key) {
                self.keyDown(with: k)
                return nil
            }
            // Allow system to handle all other defaults, like CMD+O, etc.
            return $0
        }
    }
    
    func registerNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(openedDirectory),
                                               name: Notification.Name.OpenedFolder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView),
                                               name: Notification.Name.StartPlaylist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStart(note:)),
                                               name: NSNotification.Name.StartPlayingItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenResize),
                                               name: NSWindow.didResizeNotification, object: nil)
    }
    
    func loadDefaults() {
        if let folder = self.pm.urlForCurrentPlaylist(), self.usePlaylist(folder) {
            // Found a playable playlist
            self.updateView()
            return
        }
        // No playlist show placeholder values
        self.updateViewForEmptyPlaylist()
    }
    
    func keyDown(with key: Keybinding) {
        debug_print("\(#function)")
        switch key {
        case Keybinding.PlayOrPause:
            self.playOrPause()
        case Keybinding.VolumeUp:
            self.pm.changeVolume(change: 0.01)
        case Keybinding.VolumeDown:
            self.pm.changeVolume(change: -0.01)
        case Keybinding.Loop:
            self.toggleLoop()
        case Keybinding.Random:
            self.pm.playRandomTrack()
        case Keybinding.Previous:
            self.pm.playPreviousTrack()
        case Keybinding.Next:
            self.pm.playNextTrack()
        case Keybinding.Mute:
            self.pm.mute()
        case Keybinding.Tracks:
            self.showTracksView()
        case Keybinding.Esc:
            self.hidePopOver()
        }
    }    
    
    func usePlaylist(_ folder: URL) -> Bool{
        let p = Playlist(folder: folder)
        if let error = self.pm.useCache(playlist: p), p.size() == 0 {
            debug_print(error.localizedDescription)
            
            return false
        }
        
        return true
    }
    
    func setupProgressSlider(_ duration: CMTime) {
        let max = CMTimeGetSeconds(duration)
        self.progressSlider.minValue = 0
        self.progressSlider.maxValue = Double(max)
    }
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        guard let player = pm.player else {
            return
        }
        
        let seekTime = CMTime(seconds: sender.doubleValue, preferredTimescale: 1000000000)
        player.seek(to: seekTime)
    }
    
    func updatePlayTimeLabels(_ currentTime: CMTime, _ duration: CMTime) {
        
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        self.progressSlider.doubleValue = Double(currentTimeInSeconds)
        
        let start = Date(timeIntervalSince1970: currentTimeInSeconds)
        let end = Date(timeIntervalSince1970: durationInSeconds)
        
        let fmt = DateFormatter()
        fmt.dateFormat = "mm:ss"
        
        currentTimeLabel.stringValue = fmt.string(from: start)
        durationLabel.stringValue = fmt.string(from: end)
    }
    
    func hidePopOver() {
        if self.isTracksControllerVisible {
            self.isTracksControllerVisible = false
            self.tracksViewController = nil
            self.popOverTracks?.close()
            self.popOverTracks = nil
        }
        if self.isVolumeViewControllerVisible {
            self.isVolumeViewControllerVisible = false
            self.volumeViewController = nil
            self.popOverVolume?.close()
            self.popOverVolume = nil
        }
    }
    
    // Directory management
    
    @objc func openedDirectory() {
        guard let selectedFolder = self.selectedFolder else { return }
        guard self.pm.resetPlayerState() == nil else {
            self.updateViewForEmptyPlaylist()
            return
        }
        guard self.usePlaylist(selectedFolder) else { return }
        self.pm.startPlaylist()
    }
    
    // Notification handlers
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pm.playNextTrack()
    }
    
    @objc func playerDidStart(note: NSNotification){
        self.updateView()
        self.addPeriodicTimeObserver()
        
        guard let window = self.view.window, window.level != .floating else { return }
        guard !isActive else { return }
        showPlayingNextNotification()
    }
    
    func showPlayingNextNotification() {
        guard let index = pm.getIndex() else { return }
        let track = self.pm.metadata(for: index)
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        let op = MetadataLoader(asset: self.pm.asset(for: index), track: track, completionBlock: {
            DispatchQueue.main.sync {
                let notification = NSUserNotification()
                notification.title = track.artist
                notification.subtitle = track.title
                notification.contentImage = track.artwork
                NSUserNotificationCenter.default.deliver(notification)
            }
        })
        op.start()
    }
    
    // Player observers
    
    func playerTimeProgressed() {
        guard let index = pm.getIndex() else { return }
        self.updateTimeElements(for: index)
    }
    
    func addPeriodicTimeObserver() {
        guard let player = pm.player else { fatalError("Player not setup") }
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) {
                                                            [weak self] time in
                                                            self?.playerTimeProgressed()
        }
    }
    
    func removePeriodicTimeObserver() {
        guard let player = pm.player else { return }
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // Blur handling
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.imageView?.blur()
        self.toggleTrackInfo(hidden: false)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.imageView?.unblur()
        self.toggleTrackInfo(hidden: true)
    }
    
    func toggleTrackInfo(hidden: Bool) {
        trackInfoLabel.isHidden = hidden
        trackArtistLabel.isHidden = hidden
        progressSlider.isHidden = hidden
        volumeButton.isHidden = hidden
        durationLabel.isHidden = hidden
        currentTimeLabel.isHidden = hidden
    }
    
    
    // --
    
    func popOver(for controller: NSViewController) -> NSPopover {
        let p = NSPopover()
        p.behavior = .applicationDefined
        p.contentViewController = controller
        p.delegate = self
        p.animates = true
        return p
    }
    
    func showVolumeView() {
        guard !isVolumeViewControllerVisible else { return }
        self.volumeViewController = VolumeViewController()
        self.volumeViewController?.selectorDelegate = self
        guard let volumeViewController = self.volumeViewController else { return }
        self.popOverVolume = popOver(for: volumeViewController)
        self.popOverVolume?.show(relativeTo: self.view.bounds, of: self.volumeButton, preferredEdge: .maxY)
        self.isVolumeViewControllerVisible = true
    }
}
