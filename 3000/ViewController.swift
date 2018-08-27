//
//  ViewController.swift
//  3000
//
//  Created by Alexander Alemayhu on 26/08/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    // TODO: move to wrapper class
    var player: AVPlayer?
    var currentPlaylist: Playlist?
    var playerIndex = 0
    var nowPlaying = TrackMetadata()

    var playlists = [Playlist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(openedDirectory),
                                               name: Notification.Name.OpenedFolder, object: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.OpenedFolder, object: nil)
    }
    
    func randomPosition() -> NSPoint {
        let x = CGFloat(arc4random() % uint(view.bounds.size.height))
        let y = CGFloat(arc4random() % uint(view.bounds.size.height))

        return NSPoint(x: x, y: y)
    }
    
    func loadArtwork() {
        guard let tracks = currentPlaylist?.tracks else {
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
        
        let subviews = mainView.subviews
        while imageView.frame.origin.x == 0 && imageView.frame.origin.y == 0 {
            var f = imageView.frame
            f.origin = randomPosition()
            imageView.frame = f
            imageView.frame = makeFrameForView(v: imageView, subviews: subviews)
        }
        
        print("Adding image at \(NSStringFromRect(imageView.frame))")
    }
    
    func makeFrameForView(v: NSView, subviews: [NSView]) -> NSRect {
        for v2 in subviews {
            if v.tag != v2.tag && v.frame.intersects(v2.frame) {
                return NSRect(x: 0, y: 0, width: v.frame.size.width, height: v.frame.size.height)
            }
        }
        
        return v.frame
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
            // TODO: what happens to nested folders?
            let p = Playlist(name: folder.absoluteString)
            
            do {
                let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
                p.tracks = files.filter {$0.absoluteString.hasSuffix(".mp3")}
            } catch {
                continue
            }
            
            /*
             NSString *file = @"…"; // path to some file
             CFStringRef fileExtension = (CFStringRef) [file pathExtension];
             CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
             
             if (UTTypeConformsTo(fileUTI, kUTTypeImage)) NSLog(@"It's an image");
             else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) NSLog(@"It's a movie");
             else if (UTTypeConformsTo(fileUTI, kUTTypeText)) NSLog(@"It's text");
             
             CFRelease(fileUTI);
             */
            self.playlists.append(p)
        }
        
        // For now just play the first playlist
        startFirstPlaylist()
    }
    
    
    // Player tracking
    
    func startFirstPlaylist() {
        guard self.playlists.count > 0 else { fatalError("No playlists?") }
        self.currentPlaylist = self.playlists[0]
        loadArtwork()
        play(self.currentPlaylist!)
    }
    
    func play(_ playlist: Playlist) {
        if playerIndex == playlist.tracks.count - 1 {
            print("END reached, what now?")
            playerIndex = 0
            return
        }
        
        let u = playlist.tracks[playerIndex]
        print("playing \(u)")
        let item = AVPlayerItem(url: u)
        self.player = AVPlayer(playerItem: item)
//        self.player?.volume = NSSound().volume
        self.player?.play()
        playerIndex += 1
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        guard let p = self.currentPlaylist else {
            return
        }
        play(p)
    }
}
