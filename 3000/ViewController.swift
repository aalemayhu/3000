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
        self.player = AVPlayer(url: u)
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
