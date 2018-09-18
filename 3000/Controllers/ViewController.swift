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
    
    let PlayableCollectionViewItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PlayableCollectionViewItem")
    
    // Views
    @IBOutlet weak var trackInfoLabel: NSTextField!
    @IBOutlet weak var trackArtistLabel: NSTextField!
    var imageView: LayeredBackedImageView?
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var progressSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    
    var cache = [String: Bool]()
    var pm: PlayerManager = PlayerManager()
    var selectedFolder: URL?
    
    var timeObserverToken: Any?
    var tracksController: TracksController?
    var isTracksControllerVisible = false
    
    var isActive = true
    
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
        let index = pm.getIndex()
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

        // Track progress
        self.currentTimeLabel.textColor = textColor
        self.durationLabel.textColor = textColor
        
        // Volume
        self.volumeLabel.textColor = textColor
        self.updateVolumeLabel()
        
        self.updateTimeElements(for: index)
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
        if let imageView = self.imageView {
            imageView.layer?.contents = artwork
            return
        }
        self.imageView = LayeredBackedImageView(frame: self.view.frame, andImage: artwork)
        self.view.addSubview(self.imageView!, positioned: NSWindow.OrderingMode.below, relativeTo: currentTimeLabel)
    }
    
    func loadArtwork(for index: Int, track: TrackMetadata) {
        let op = MetadataLoader(asset: self.pm.asset(for: index), track: track, completionBlock: {
            DispatchQueue.main.sync {
                self.updateArtwork(with: track.artwork)
            }
        })
        op.start()
    }
    
    func updateVolumeLabel() {
        // Show new volume
        let sv = String.init(format: "%.f", pm.getVolume()*100)
        self.volumeLabel.stringValue = "\(sv)%🔊"
    }
    
    func textColor(for background: NSImage?) -> NSColor{
        guard let image = background else {
            return NSColor.black
        }
        // https://stackoverflow.com/questions/24595908/swift-nsimage-to-cgimage
        // TODO: locate most dominant color
        var imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        // end
        let bitmapRep = NSBitmapImageRep(cgImage: imageRef!)
        let imageSize = image.size
        if let color = bitmapRep.colorAt(x: Int(imageSize.width/2), y: Int(imageSize.height/2))?.contrast() {
            return color
        }
        return NSColor.black
    }
    
    @objc func screenResize() {
        let fontSize = max(self.view.frame.size.width/28, 13)
        self.trackArtistLabel.font = NSFont(name: "Helvetica Neue Bold", size: fontSize)
        self.trackInfoLabel.font = NSFont(name: "Helvetica Neue Light", size: fontSize)
        
        self.currentTimeLabel.font = NSFont(name: "Helvetica Neue", size: fontSize)
        self.durationLabel.font = NSFont(name: "Helvetica Neue", size: fontSize)
        self.volumeLabel.font = NSFont(name: "Helvetica Neue", size: fontSize)
        
        self.imageView?.setFrameSize(self.view.frame.size)
    }
    
    
    // ---
    
    func configure () {
        // Add notification observers
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
        // Handle keyboard
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            // Only handle supported keybindings
            if let key = $0.characters, let k = Keybinding(rawValue: key) {
                self.keyDown(with: k)
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
        if let folder = StoredDefaults.getLastPath() {
            let _ = self.usePlaylist(folder)
        } else {
            debug_print("No cached folder")
        }
    }
    
    func keyDown(with key: Keybinding) {
        debug_print("\(#function)")
        switch key {
        case Keybinding.PlayOrPause:
            self.playOrPause()
        case Keybinding.VolumeUp:
            self.pm.changeVolume(change: 0.01)
            self.updateVolumeLabel()
        case Keybinding.VolumeDown:
            self.pm.changeVolume(change: -0.01)
            self.updateVolumeLabel()
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
            self.dismissTracksViewController()
        }
    }    
    
    func usePlaylist(_ folder: URL) -> Bool{
        let p = Playlist(folder: folder)
        if let error = self.pm.useCache(playlist: p), p.size() == 0 {
            debug_print(error.localizedDescription)
            return false
        }
        
        self.updateView()
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
    
    // Directory management
    
    @objc func openedDirectory() {
        guard let selectedFolder = self.selectedFolder else { return }
        
        if let error = self.pm.resetPlayerState() {
            debug_print("ERROR: \(error.localizedDescription)")
        }
        if self.usePlaylist(selectedFolder) {
            self.pm.startPlaylist()
        }
    }
    
    // Notification handlers
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pm.playNextTrack()
    }
    
    @objc func playerDidStart(note: NSNotification){
        self.updateView()
        self.addPeriodicTimeObserver()
        
        guard !isActive else { return }
        showPlayingNextNotification()
    }
    
    func showPlayingNextNotification() {
        let index = pm.getIndex()
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
        debug_print("\(#function)")
        self.updateTimeElements(for: self.pm.getIndex())
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
        volumeLabel.isHidden = hidden
        durationLabel.isHidden = hidden
        currentTimeLabel.isHidden = hidden
    }
}

extension ViewController: TracksControllerSelector {
  
    func numberOfTracks() -> Int {
        return self.pm.trackCount()
    }
    
    func currentArtwork() -> NSImage? {
        return self.imageView?.layer?.contents as? NSImage
    }

    func dismissTracksViewController() {
        guard self.isTracksControllerVisible, let t = self.tracksController else { return }
        self.dismissViewController(t)
        self.isTracksControllerVisible = false
    }
    
    func trackInfo(at index: Int) -> TrackListInfo {
        return self.pm.trackInfo(for: index)
    }
    
    func didSelectTrack(index: Int) {
        self.dismissTracksViewController()
        self.pm.playFrom(index)
    }
}
