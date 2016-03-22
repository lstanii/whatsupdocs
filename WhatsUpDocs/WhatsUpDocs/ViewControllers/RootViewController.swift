//
//  ViewController.swift
//  WhatsUpDocs
//
//  Created by default on 3/17/16.
//  Copyright © 2016 Rebel Creators. All rights reserved.
//

import UIKit
import FileCenter

class RootViewController: FolderViewController {
    override func viewDidLoad() {
        folder = FileCenter.documents()
        
        super.viewDidLoad()
    }
}

