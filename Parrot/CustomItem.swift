//
//  CustomItem.swift
//  Parrot
//
//  Created by tenda_dev on 2017/9/20.
//  Copyright © 2017年 tomjoy1947. All rights reserved.
//

import Cocoa

class CustomItem: NSCollectionViewItem {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var inputField: NSTextView!
    @IBOutlet weak var titleLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
