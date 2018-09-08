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
    @IBOutlet weak var trackInfoLabel: NSTextField!
    @IBOutlet weak var trackArtistLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var progressSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    
    var cachedTracksData = [TrackMetadata]()
    var cache = [String: Bool]()
    var pm: PlayerManager?
    
    var timeObserverToken: Any?
    
    // View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // View changes
    
    @objc func updateView() {
        let index = pm?.getIndex() ?? 0
        let track = self.cachedTracksData[index]
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        // Album image
        self.imageView.image = track.artwork
        
        // Track info
        self.trackInfoLabel.stringValue = "🎵 \(title)"
        self.trackArtistLabel.stringValue = "\(artist)"
        
        // Either use the playing items duration or load from currently not playing item
        guard let pm = self.pm else { return }
        let playTime = pm.playTime(index: index)
        let duration = playTime.duration ?? AVURLAsset(url: pm.tracks()[index], options: PlayerManager.AssetOptions).duration
        let currentTime = playTime.currentTime ?? CMTime(seconds: 0, preferredTimescale: 1000000000)
        
        self.setupProgressSlider(duration)
        self.updatePlayTimeLabels(currentTime, duration)
        self.updateVolumeLabel()
    }
    
    func updateVolumeLabel() {
        guard let v = pm?.getVolume() else {
            // TODO: handle volume is not set
            return
        }
        
        // Show new volume
        let sv = String.init(format: "%.f", v*100)
        self.volumeLabel.stringValue = "\(sv)%🔊"
    }
    
    @objc func screenResize() {
        print("TODO: resize font")
    }
    
    
    // ---
    
    func configure () {
        // Add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(openedDirectory),
                                               name: Notification.Name.OpenedFolder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView),
                                               name: Notification.Name.StartFirstPlaylist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStart(note:)),
                                               name: NSNotification.Name.StartPlayingItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenResize),
                                               name: NSWindow.didResizeNotification, object: nil)
        // Handle keyboard
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            // Only handle supported keybindings
            if let key = $0.characters, Keybinding(rawValue: key) != nil {
                self.keyDown(with: $0)
                return nil
            }
            // Allow system to handle all other defaults, like CMD+O, etc.
            return $0
        }
        
        loadDefaults()
        progressSlider.trackFillColor = NSColor.gray
        
        toggleTrackInfo(hidden: true)
    }
    
    func loadDefaults() {
        if let folder = UserDefaults.standard.url(forKey: StoredDefaults.LastPath) {
            self.load(folder)
        } else {
            debug_print("No cached folder")
        }
    }
    
    override func keyDown(with event: NSEvent) {
        debug_print("\(#function)")
        guard let pm = self.pm else { return }
        switch event.characters {
        case Keybinding.PlayOrPause.rawValue:
            pm.playOrPause()
        case Keybinding.VolumeUp.rawValue:
            // TODO: prevent going beyond 100%
            self.pm?.changeVolume(change: 0.01)
            self.updateVolumeLabel()
        case Keybinding.VolumeDown.rawValue:
            self.pm?.changeVolume(change: -0.01)
            self.updateVolumeLabel()
        case Keybinding.Loop.rawValue:
            self.toggleLoop()
        case Keybinding.Random.rawValue:
            self.pm?.playRandomTrack()
        case Keybinding.Previous.rawValue:
            self.pm?.playPreviousTrack()
        case Keybinding.Next.rawValue:
            self.pm?.playNextTrack()
        case Keybinding.Mute.rawValue:
            self.pm?.mute()
        default:
            debug_print("unknown key")
        }
    }
    
    func toggleLoop() {
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
    
    func load(_ folder: URL) {                
        let p = Playlist(folder: folder)
        self.pm = PlayerManager(playlist: p)
        self.cachedTracksData = p.loadFiles(folder)
        self.pm?.useCache(playlist: p)
        
        self.updateView()
        
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.pm = self.pm
        }
    }
    
    func setupProgressSlider(_ duration: CMTime) {
        let max = CMTimeGetSeconds(duration)
        self.progressSlider.minValue = 0
        self.progressSlider.maxValue = Double(max)
    }
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        guard let pm = self.pm, let player = pm.player else {
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
        
        // TODO: handle hours
        let fmt = DateFormatter()
        fmt.dateFormat = "mm:ss"
        
        currentTimeLabel.stringValue = fmt.string(from: start)
        durationLabel.stringValue = fmt.string(from: end)
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
        self.updateView()
        self.addPeriodicTimeObserver()
    }
    
    // Player observers
    
    func playerTimeProgressed() {
        guard let pm = self.pm else { return }
        let playTime = pm.playTime()
        
        guard  let currentTime = playTime.currentTime,
            let duration = playTime.duration else {
                return
        }
        
        updatePlayTimeLabels(currentTime, duration)
    }
    
    func addPeriodicTimeObserver() {
        guard let pm = self.pm, let player = pm.player else { return }
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
        guard let pm = self.pm, let player = pm.player else { return }
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // Blur handling
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.imageView.blur()
        self.toggleTrackInfo(hidden: false)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.imageView.unblur()
        self.toggleTrackInfo(hidden: true)
    }
    
    func toggleTrackInfo(hidden: Bool) {
        trackInfoLabel.isHidden = hidden
        trackArtistLabel.isHidden = hidden
        progressSlider.isHidden = hidden
        volumeLabel.isHidden = hidden
        durationLabel.isHidden = hidden
        currentTimeLabel.isHidden = hidden
    }
}
