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
}

class TracksController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    var selectorDelegate: TracksControllerSelector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension TracksController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print("\(#function)")
        selectorDelegate?.didSelectTrack(index: 0)
        return true
    }
}

extension TracksController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("\(#function)")
        return 2
    }
    
    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
        print("\(#function)")
        return nil
    }
}
