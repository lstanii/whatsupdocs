//
//  TextEditorViewController.swift
//  WhatsUpDocs
//
//  Created by default on 3/19/16.
//  Copyright © 2016 Rebel Creators. All rights reserved.
//

import UIKit
import CryptoSwift
import FileCenter
import RichEditorView

class TextEditorViewController: RichEditorViewViewController {
    
    var file : File?
    var saveBtn : UIBarButtonItem?
    var textContentHash : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveBtn = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        navigationItem.rightBarButtonItem = self.saveBtn
        
        FileCenter.performInBackground({
            if let data = self.file?.fetch() {
                if let html = String(data: data, encoding: NSUTF8StringEncoding) {
                    FileCenter.performOnMainQueue({
                        self.setHTML(html)
                    })
                }
            }
            }, completion: {
                self.generateHash()
        })
        self.saveBtn?.enabled = false
    }
    
    func showMsg(title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let ok = UIAlertAction(title: "Ok", style: .Cancel, handler: { action in
        })
        
        alertController.addAction(ok)
        view.userInteractionEnabled = false
        presentViewController(alertController, animated: true) { () -> Void in
            self.view.userInteractionEnabled = true
        }
    }
    
    func richEditor(editor: RichEditorView, contentDidChange content: String) {
        saveBtn?.enabled = editor.getText().md5() != self.textContentHash
    }
    
    func save() {
        if let data = self.getHTML()?.dataUsingEncoding(NSUTF8StringEncoding), let file = file {
            FileCenter.performInBackground({
                if !file.save(data) {
                    FileCenter.performOnMainQueue({
                        self.showMsg("Couldn't save file", message: "Please try again")
                    })
                }
                }, completion:{
                    self.generateHash()
                    self.saveBtn?.enabled = false
            })
        }
    }
    
    func generateHash() {
        if let text = self.editor?.getText() {
            self.textContentHash = text.md5()
        }else {
            self.textContentHash = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
