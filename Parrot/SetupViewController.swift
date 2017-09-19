//
//  ViewController.swift
//  Parrot
//
//  Created by tenda_dev on 2017/9/14.
//  Copyright © 2017年 tomjoy1947. All rights reserved.
//

import Cocoa

class SetupViewController: NSViewController {

    @IBOutlet weak var workspacePathField: NSTextField!
    @IBOutlet weak var tipLabel: NSTextField!
    let pathKey = "pathKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.autoCheckSetup()
    }


    @IBAction func openFinder(_ sender: NSButton) {
        let openpanel = NSOpenPanel()
        openpanel.allowsMultipleSelection = false
        openpanel.canChooseDirectories = true
        openpanel.canCreateDirectories = false
        openpanel.canChooseFiles = false
        
        openpanel.begin { (result) in
            if result.rawValue == 1 {
                let defaults = UserDefaults.standard
                defaults.set(openpanel.url, forKey: self.pathKey)
                self.workspacePathField.stringValue = (openpanel.url?.absoluteString)!
                self.autoCheckSetup()
            } else {
                self.tipLabel.stringValue = "please choose your workspace patch"
            }
        }
    }
    
    func autoCheckSetup() {
        if let path = UserDefaults.standard.url(forKey: pathKey) {
            let story = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let viewController = story.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EditViewController")) as! EditViewController
            viewController.path = path
            self.view.window!.contentViewController = viewController
        }
    }
    
    
}

