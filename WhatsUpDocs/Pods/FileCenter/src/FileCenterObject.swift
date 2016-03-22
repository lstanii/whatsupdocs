// Copyright (c) 2016 Rebel Creators
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public class FileCenterObject : NSObject {
    
    //MARK: Private Properties
    
    
    private var path : String
    
    
    //MARK: Public Properties
    
    
    public private(set) var containingFolder : Folder?
    
    
    //MARK: Init
    
    
    init(containingFolder : Folder?, path : String) {
        var container = containingFolder
        var objectPath = path
        let components = path.componentsSeparatedByString(FileCenter.separator)
        
        for var i = 0; i < components.count - 1; i++ {
            container = Folder(containingFolder: container, path: components[i])
            objectPath = components[i + 1]
        }
        
        self.containingFolder = container
        self.path = objectPath
        
        super.init()
    }
    
    
    //MARK: Internal Methods
    
    
    internal func buildPath(object : FileCenterObject) -> String {
        let path = object.path
        
        guard let parent = object.containingFolder else {
            return path
        }
        
        return "\(buildPath(parent))\(FileCenter.separator)\(path)"
    }
    
    
    internal func buildRelativePath(object : FileCenterObject) -> String {
        let path = object.path
        
        guard let parent = object.containingFolder where !(parent is BaseFolder)  else {
            return path
        }
        
        return "\(buildRelativePath(parent))\(FileCenter.separator)\(path)"
    }
    
    
    //MARK: Public Methods
    
    
    /*
    let NSFileAppendOnly: String
    let NSFileBusy: String
    let NSFileCreationDate: String
    let NSFileOwnerAccountName: String
    let NSFileGroupOwnerAccountName: String
    let NSFileDeviceIdentifier: String
    let NSFileExtensionHidden: String
    let NSFileGroupOwnerAccountID: String
    let NSFileHFSCreatorCode: String
    let NSFileHFSTypeCode: String
    let NSFileImmutable: String
    let NSFileModificationDate: String
    let NSFileOwnerAccountID: String
    let NSFilePosixPermissions: String
    let NSFileReferenceCount: String
    let NSFileSize: String
    let NSFileSystemFileNumber: String
    let NSFileType: String
    let NSFileProtectionKey: String
    
    More info : https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class
    */
    public func attributes() -> [String : AnyObject]? {
        do {
            return try FileCenter.fileManager.attributesOfItemAtPath(buildPath(self))
        } catch {
            return nil
        }
    }
    
    public func delete() -> Bool {
        do {
            try FileCenter.fileManager.removeItemAtPath(buildPath(self))
            
            return true
        } catch {
            return false
        }
    }
    
    public func exists() -> Bool {
        return FileCenter.fileManager.fileExistsAtPath(buildPath(self))
    }
    
    public func fullURL() -> NSURL? {
        return NSURL(string: buildPath(self))
    }
    
    public func isDeletable() -> Bool {
        return FileCenter.fileManager.isDeletableFileAtPath(buildPath(self))
    }
    
    public func name() -> String {
        return path
    }
    
    public func url() -> NSURL? {
        return NSURL(string: buildRelativePath(self))
    }
    
    public func rename( name : String) -> Bool {
        return false
    }
}
