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
        
        if let newFrame = NSApplication.shared.windows.first?.contentView?.bounds {
            self.view.frame = newFrame
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        configure()
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
        let playTime = pm.playTime()
        let duration = playTime.duration ?? AVPlayerItem(url: pm.tracks()[index]).asset.duration
        
        self.setupProgressSlider(duration)
        self.updatePlayTimeLabels(CMTime(seconds: 0, preferredTimescale: 1000000000), duration)
    }
    
    func updateVolume(change: Float) {
        guard let pm = self.pm else { return }
        // TODO: prevent going beyond 100%
        // Change the player volume
        pm.changeVolume(change: change)
        // Show new volume
        if let v = pm.getVolume() {
            let sv = String.init(format: "%.f", v*100)
            self.volumeLabel.stringValue = "\(sv)%🔊"
        }
    }
    
    
    // ---
    
    func configure () {
        NotificationCenter.default.addObserver(self, selector: #selector(openedDirectory),
                                               name: Notification.Name.OpenedFolder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView),
                                               name: Notification.Name.StartFirstPlaylist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStart(note:)),
                                               name: NSNotification.Name.StartPlayingItem, object: nil)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return nil
        }
        
        loadDefaults()
        
        progressSlider.trackFillColor = NSColor.gray
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
        case " ":
            pm.playOrPause()
        case "+":
            self.updateVolume(change: 0.01)
        case "-":
            self.updateVolume(change: -0.01)
        case "l":
            self.toggleLoop()
        case "r":
            self.pm?.playRandomTrack()
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
}
