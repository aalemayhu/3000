//
//  TracksController.swift
//  3000
//
//  Created by ccscanf on 11/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

protocol TracksControllerSelector {
    func didSelectTrack(index: Int)
    func tracks() -> [TrackMetadata]
}

class TracksController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    var selectorDelegate: TracksControllerSelector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    func configure() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
}

extension TracksController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print("\(#function)")
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

extension TracksController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let del = self.selectorDelegate else { return 0 }
        return del.tracks().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        let identifier = NSUserInterfaceItemIdentifier(rawValue: tableColumn.title)
        guard let res = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView else { return nil}
        guard let del = self.selectorDelegate else { return nil }

        if tableColumn.title == "Artist", let artist = del.tracks()[row].artist {
            res.textField?.stringValue = artist
        } else if let title = del.tracks()[row].title {
            res.textField?.stringValue = title
        }
        return res
    }
}