//
//  TracksViewController.swift
//  3000
//
//  Created by ccscanf on 17/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

extension TracksViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        debug_print("\(#function)")
        selectorDelegate?.didSelectTrack(index: row)
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
}

extension TracksViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let del = self.selectorDelegate else { return 0 }
        return del.numberOfTracks()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        let identifier = NSUserInterfaceItemIdentifier(rawValue: tableColumn.title)
        guard let res = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView else { return nil}
        guard let del = self.selectorDelegate else { return nil }
        
        let trackInfo = del.trackInfo(at: row)
        if tableColumn.title == "Artist" {
            res.textField?.stringValue = trackInfo.artist
        } else if tableColumn.title == "Title" {
            res.textField?.stringValue = trackInfo.title
        }
        res.textField?.backgroundColor = NSColor.clear
        
        return res
    }
}
