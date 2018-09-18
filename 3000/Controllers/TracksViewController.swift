//
//  TracksViewController.swift
//  3000
//
//  Created by ccscanf on 11/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Cocoa

class TracksViewController: NSViewController {
    
    var selectorDelegate: TracksViewControllerSelector?
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var imageView: NSImageView!
    
    init(selectorDelegate: TracksViewControllerSelector) {
        super.init(nibName: NSNib.Name(rawValue: "TracksViewController"), bundle: Bundle.main)
        self.selectorDelegate = selectorDelegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.reloadData()
    }
    
    func configure() {
        self.tableView.delegate = self
        self.tableView.dataSource = self        
        self.reloadData()
    }
    
    func reloadData() {
        self.tableView.reloadData()
        if let image = selectorDelegate?.currentArtwork() {
            self.imageView.image = image
        }
    }
}
