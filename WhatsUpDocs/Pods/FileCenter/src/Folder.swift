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

public class Folder : FileCenterObject {
    
    
    //MARK: Public Methods
    
    
    public func create() -> Bool {
        guard !exists() else {
            return false
        }
        
        do {
            try FileCenter.fileManager.createDirectoryAtPath(buildPath(self), withIntermediateDirectories: true, attributes: nil)
            
            return true
        } catch {
            return false
        }
    }
    
    public func folder(name : String) -> Folder {
        return Folder(containingFolder: self, path: name)
    }
    
    public func file(name :String) -> File {
        return File(containingFolder: self, path: name)
    }
    
    public func list() -> [String] {
        do {
            return try FileCenter.fileManager.contentsOfDirectoryAtPath(buildPath(self))
        } catch {
            return []
        }
    }
    
    public override func rename(name : String) -> Bool {
        if let newURL = self.containingFolder?.folder(name).fullURL(), let url = self.fullURL() {
            do {
                try FileCenter.fileManager.moveItemAtURL(url, toURL: newURL)
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
}