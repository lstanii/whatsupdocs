//
//  FolderViewController.swift
//  WhatsUpDocs
//
//  Created by default on 3/17/16.
//  Copyright © 2016 Rebel Creators. All rights reserved.
//

import UIKit
import FileCenter

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView : UITableView?
    var folder : Folder!
    var files : [String] = []
    @IBOutlet var addBtn : UIBarButtonItem?
    
    init() {
        super.init(nibName: String(FolderViewController.self), bundle: NSBundle(forClass: FolderViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = folder.name()
        navigationController?.setNavigationBarHidden(false, animated: true)
        addBtn = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
        navigationItem.rightBarButtonItem = self.addBtn
        tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reload()
    }
    
    func reload() {
        FileCenter.performInBackground({
            self.files = self.folder.list()
            }, completion: {
                self.tableView?.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let name = files[indexPath.row]
        cell?.textLabel?.text = name
        let folder = self.folder.folder(files[indexPath.row])
        if let fileType = folder.attributes()?[NSFileType] as? String where fileType ==  NSFileTypeDirectory {
            cell?.imageView?.image = UIImage(named: "folder")
        } else {
            cell?.imageView?.image = UIImage(named: "file")
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var title = "Delete File"
        let folder = self.folder.folder(self.files[indexPath.row])
        if let fileType = folder.attributes()?[NSFileType] as? String where fileType ==  NSFileTypeDirectory {
          title = "Delete Directory"
        }
        
        let delete = UITableViewRowAction(style: .Default, title: title, handler: { action , indexpath in
            folder.delete()
            self.reload()
        })
        
        return [delete]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let folder = self.folder.folder(files[indexPath.row])
        let fil = folder.attributes()?[NSFileType]
        print(fil)
        if let fileType = folder.attributes()?[NSFileType] as? String where fileType ==  NSFileTypeDirectory {
            let folderViewController = FolderViewController()
            folderViewController.folder = folder
            
            self.navigationController?.pushViewController(folderViewController, animated: true)
        } else {
            let textEditor = TextEditorViewController()
            textEditor.file = self.folder.file(files[indexPath.row])
            navigationController?.pushViewController(textEditor, animated: true)
        }
    }
    
    func add() {
        let alertController = UIAlertController(title: "New", message: "", preferredStyle:.ActionSheet)
        let folder = UIAlertAction(title: "Folder", style: .Default, handler: { action in
            self.addFolder()
        })
        let textFile = UIAlertAction(title: "Text FIle", style: .Default, handler: { action in
            self.addFile()
        })
        
        alertController.addAction(folder)
        alertController.addAction(textFile)
        view.userInteractionEnabled = false
        presentViewController(alertController, animated: true) { () -> Void in
            self.view.userInteractionEnabled = true
        }
    }
    
    func addFile() {
        let alertController = UIAlertController(title: "File Name", message: "Enter a unique file name", preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
        })
        
        let add = UIAlertAction(title: "Add", style: .Default, handler: { action in
            if let name = alertController.textFields?[0].text {
                self.createFile(name)
            }
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "File Name"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                add.enabled = textField.text?.characters.count > 0
            }
        }
        
        alertController.addAction(cancel)
        alertController.addAction(add)
        view.userInteractionEnabled = false
        presentViewController(alertController, animated: true) { () -> Void in
            self.view.userInteractionEnabled = true
        }
    }
    
    func addFolder() {
        let alertController = UIAlertController(title: "Folder Name", message: "Enter a unique folder name", preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
        })
        
        let add = UIAlertAction(title: "Add", style: .Default, handler: { action in
            if let name = alertController.textFields?[0].text {
                self.createFolder(name)
            }
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Folder Name"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                add.enabled = textField.text?.characters.count > 0
            }
        }
        
        alertController.addAction(cancel)
        alertController.addAction(add)
        view.userInteractionEnabled = false
        presentViewController(alertController, animated: true) { () -> Void in
            self.view.userInteractionEnabled = true
        }
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
    
    func createFile(name : String) {
        guard !folder.file(name).exists() else {
            showMsg("File Exists", message: "Sorry, that file already exists")
            return
        }
        
        FileCenter.performInBackground({
            self.folder.file(name).save(NSData())
            }, completion: {
                self.reload()
        })
    }
    
    func createFolder(name : String) {
        guard !folder.folder(name).exists() else {
            showMsg("Folder Exists", message: "Sorry, that folder already exists")
            return
        }
        
        FileCenter.performInBackground({
            self.folder.folder(name).create()
            }, completion: {
                self.reload()
        })
    }
}
