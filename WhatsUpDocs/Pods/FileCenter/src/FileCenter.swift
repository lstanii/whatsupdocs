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

public class FileCenter {
    
    
    //MARK: Public Properties
    
    
    public static let defaultCenter = FileCenter()
    public static let fileManager = NSFileManager.defaultManager()
    public static let separator = "/"
    public static var sharedCache : NSCache? = NSCache()
    
    
    //MARK: Internal Properties
    
    
    internal static var enableCaching = true
    
    
    //MARK: Public Methods
    //MARK: Base Directories
    
    
    public func documents() -> BaseFolder {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        return BaseFolder(containingFolder: nil, path: documentsPath)
    }
    
    public func library() -> BaseFolder {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0]
        
        return BaseFolder(containingFolder: nil, path: libraryPath)
    }
    
    public func temp() -> BaseFolder {
        let tmpPath = NSTemporaryDirectory()
        
        return BaseFolder(containingFolder: nil, path: tmpPath)
    }
    
    
    //MARK: Public Static Methods
    
    
    public static func disableCachingInBlock(block : (() -> Void)) {
        objc_sync_enter(enableCaching)
        enableCaching = false
        block()
        enableCaching = true
        objc_sync_exit(enableCaching)
    }
    
    public static func performInBackground(block : (() -> Void), completion : (() -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            block()
            if let comp = completion {
                self.performOnMainQueue(comp)
            }
        })
    }
    
    public static func performOnMainQueue(block : (() -> Void)) {
        guard !NSThread.isMainThread() else {
            block()
            
            return
        }
        
        dispatch_sync(dispatch_get_main_queue(), {
            block()
        })
    }
    
    
    //MARK: Base Directories
    
    
    public static func documents() -> BaseFolder {
        return defaultCenter.documents()
    }
    
    public static func library() -> BaseFolder {
        return defaultCenter.library()
    }
    
    public static func temp() -> BaseFolder {
        return defaultCenter.temp()
    }
}