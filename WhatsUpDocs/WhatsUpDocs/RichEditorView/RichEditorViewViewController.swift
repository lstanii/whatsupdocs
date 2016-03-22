//
//  RichEditorViewViewController.swift
//  WhatsUpDocs
//
//  Created by default on 3/19/16.
//  Copyright © 2016 Rebel Creators. All rights reserved.
//

import UIKit
import RichEditorView

class RichEditorViewViewController: UIViewController, RichEditorDelegate {
    var editor : RichEditorView?
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorOptions.all()
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editor = RichEditorView(frame: self.view.bounds)
        editor?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        editor?.inputAccessoryView = self.toolbar
        editor?.delegate = self
        if let editor = self.editor {
            self.view.addSubview(editor)
        }
        
        toolbar.editor = editor
        
        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar?.editor?.setHTML("")
        }
        
        var options = toolbar.options
        options.append(item)
        toolbar.options = options
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setEditorHeight(self.view.bounds.size.height)
        editor?.focus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({coordinator in
            }, completion: { coordinator in
                self.setEditorHeight(self.view.bounds.size.height)
        })
    }
    
    func setEditorHeight(height : CGFloat) {
        self.editor?.runJS("var editorRC = document.getElementById('editor'); if (editorRC.clientHeight < \(height)) { editorRC.setAttribute(\"style\",\"min-height:\(height)px\"); }")
    }
    
    func setHTML(html : String) {
        editor?.setHTML(html)
    }
    
    func getHTML() -> String? {
        return editor?.getHTML()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
