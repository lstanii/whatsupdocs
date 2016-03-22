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

public class BaseFolder : Folder {
    
    public func generateWithURL(url : NSURL) -> FileCenterObject? {
        guard let path = url.path else {
            return nil
        }
        
        return generateWithPath(path)
    }
    
    public func generateWithPath(path : String) -> FileCenterObject? {
        var directoryPath = path as NSString
        var fileName : String?
        if let lastComponent = directoryPath.lastPathComponent as NSString? where !lastComponent.pathExtension.isEmpty {
            directoryPath = directoryPath.stringByDeletingLastPathComponent
            fileName = lastComponent as String
        }
        
        var llObject : FileCenterObject = Folder(containingFolder: self, path: directoryPath as String)
        if let name = fileName, let folderObject = llObject as? Folder {
            llObject = folderObject.file(name)
        }
        
        return llObject
    }
}
