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
    
    var playlists = [Playlist]()
    var player: AVPlayer?
    
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

    @objc func openedDirectory() {
        guard let delegate = NSApp.delegate as? AppDelegate else {
            return
        }
        
        print("opened: \(delegate.folders)")
        // TODO: handle duplicated
        // TODO: handle case where no playable files have been found
        
        // Traverse the directory for audio files
        for folder in delegate.folders {
            // TODO: what happens to nested folders?
            let p = Playlist(name: folder.absoluteString)
            
            do {
                let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
                p.tracks = files.filter {$0.absoluteString.hasSuffix(".mp3")}
            } catch {
                continue
            }
            self.playlists.append(p)
        }
        
        if self.playlists[0].tracks.count > 0 {
            play(self.playlists[0].tracks[0])
            print("YEAH")
            
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
        
    }
    
    func play(_ url: URL) {
        self.player = AVPlayer(url:url)
        self.player?.play()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.OpenedFolder, object: nil)
    }
}

