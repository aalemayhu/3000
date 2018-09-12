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
    var imageView: LayeredBackedImageView?
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var progressSlider: NSSlider!
    @IBOutlet weak var volumeLabel: NSTextField!
    
    var cachedTracksData = [TrackMetadata]()
    var cache = [String: Bool]()
    var pm: PlayerManager = PlayerManager()
    
    var timeObserverToken: Any?
    var tracksController: TracksController?
    var isTracksControllerVisible = false
    
    // View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // View changes
    
    @objc func updateView() {
        let index = pm.getIndex()
        let track = self.cachedTracksData[index]
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        // Album image
        updateArtwork(with: track.artwork)
        
        // Track info
        let textColor = self.textColor(for: track.artwork)
        self.trackInfoLabel.stringValue = "\(title)"
        self.trackArtistLabel.stringValue = "\(artist)"
        self.trackInfoLabel.textColor = textColor
        self.trackArtistLabel.textColor = textColor

        // Track progress
        self.currentTimeLabel.textColor = textColor
        self.durationLabel.textColor = textColor
        
        // Volume
        self.volumeLabel.textColor = textColor
        
        // Either use the playing items duration or load from currently not playing item
        let playTime = pm.playTime(index: index)
        let duration = playTime.duration ?? AVURLAsset(url: pm.tracks()[index], options: PlayerManager.AssetOptions).duration
        let currentTime = playTime.currentTime ?? CMTime(seconds: 0, preferredTimescale: 1000000000)
        
        self.setupProgressSlider(duration)
        self.updatePlayTimeLabels(currentTime, duration)
        self.updateVolumeLabel()
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
    
    func showTracksView() {
        guard !isTracksControllerVisible else { return }
        if self.tracksController == nil {
            self.tracksController = TracksController(nibName: NSNib.Name(rawValue: "TracksController"), bundle: Bundle.main)
            self.tracksController?.selectorDelegate = self
        } else {
            self.tracksController?.reloadData()
        }
        // TODO: use animation slide in / fade in
        self.presentViewControllerAsSheet(self.tracksController!)
        
        self.isTracksControllerVisible = true
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
        if let folder = UserDefaults.standard.url(forKey: StoredDefaults.LastPath) {
            self.usePlaylist(folder)
        } else {
            debug_print("No cached folder")
        }
    }
    
    func keyDown(with key: Keybinding) {
        debug_print("\(#function)")
        switch key {
        case Keybinding.PlayOrPause:
            // TODO: handle case where player manager a empty playlist
            pm.playOrPause()
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
    
    func toggleLoop() {
        if (!pm.getIsLooping()) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            pm.loopTrack()
        } else {
            pm.stopLooping()
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    func usePlaylist(_ folder: URL) {                
        let p = Playlist(folder: folder)
        self.cachedTracksData = p.loadFiles(folder)
        guard self.cachedTracksData.count > 0 else {
            let alert = NSAlert.init()
            alert.addButton(withTitle: "OK")
            alert.messageText = "No playable tracks in \(folder). Try a different folder with mp3s (CMD+O)"
            alert.runModal()
            alert.alertStyle = .critical
            return
        }
        
        self.pm.useCache(playlist: p)
        
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
        
        // TODO: handle hours
        let fmt = DateFormatter()
        fmt.dateFormat = "mm:ss"
        
        currentTimeLabel.stringValue = fmt.string(from: start)
        durationLabel.stringValue = fmt.string(from: end)
    }
    
    // Directory management
    
    @objc func openedDirectory() {
        // TODO: drop app delegate usage
        guard let delegate = NSApp.delegate as? AppDelegate,
            let selectedFolder = delegate.selectedFolder else {
                return
        }
        // TODO: handle case where no playable files have been found
        // TODO: what happens to nested folders?        
        self.pm.resetPlayerState()
        self.usePlaylist(selectedFolder)
        self.pm.startPlaylist()
    }
    
    // Notification handlers
    
    
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pm.playNextTrack()
    }
    
    @objc func playerDidStart(note: NSNotification){
        self.updateView()
        self.addPeriodicTimeObserver()
    }
    
    // Player observers
    
    func playerTimeProgressed() {
        let playTime = pm.playTime()
        
        guard  let currentTime = playTime.currentTime,
            let duration = playTime.duration else {
                return
        }
        
        updatePlayTimeLabels(currentTime, duration)
    }
    
    func addPeriodicTimeObserver() {
        guard let player = pm.player else { return }
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

    func dismissTracksViewController() {
        guard let t = self.tracksController else { return }
        self.dismissViewController(t)
        self.isTracksControllerVisible = false
    }
    
    func tracks() -> [TrackMetadata] {
        return self.cachedTracksData
    }
    
    func didSelectTrack(index: Int) {
        self.dismissTracksViewController()
        self.pm.playFrom(index)
    }
}
