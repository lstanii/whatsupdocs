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

public class Downloadable : NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    
    //MARK: Private Properties
    
    
    private var data : NSMutableData?
    private var failure : ((error : NSError) -> Void)?
    private var file : File
    private var progress : ((progress : Float) -> Void)?
    private var success : ((data : NSData) -> Void)?
    private var url : NSURL
    
    
    //MARK: Init
    
    
    init(file : File, url : NSURL) {
        self.file = file
        self.url = url
        
        super.init()
    }
    
    
    //MARK: Private Methods
    
    
    private func finish() -> Bool {
        if let data = self.data {
            return self.file.save(data)
        } else {
            return false
        }
    }
    
    
    //MARK: Public Methods
    
    
    public func failure(failure : ((error : NSError) -> Void)) -> Downloadable {
        self.failure = failure
        
        return self
    }
    
    public func progress(progress : ((progress : Float) -> Void)) -> Downloadable {
        self.progress = progress
        
        return self
    }
    
    public func save() -> NSURLSessionDataTask {
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(NSUUID().UUIDString)
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue())
        let dataTask = session.dataTaskWithURL(url)
        dataTask.resume()
        
        return dataTask
    }
    
    public func success(success : ((data : NSData) -> Void)) -> Downloadable {
        self.success = success
        
        return self
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        assert(!NSThread.isMainThread(), "Should not be called directly - will lock main thread")
        
        self.data?.appendData(data)
        dispatch_sync(dispatch_get_main_queue(), {
            self.progress?(progress : Float(dataTask.countOfBytesReceived) / Float(dataTask.countOfBytesExpectedToReceive))
        })
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        self.data = NSMutableData()
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        assert(!NSThread.isMainThread(), "Should not be called directly - will lock main thread")
        
        guard error == nil else {
            if let e = error {
                dispatch_sync(dispatch_get_main_queue(), {
                    self.failure?(error: e)
                })
            }
            
            return
        }
        if self.finish() {
            dispatch_sync(dispatch_get_main_queue(), {
                var data = NSData()
                if let contents = self.data {
                    data = contents
                }
                self.success?(data : data)
            })
        } else {
            var userInfo : [NSObject : AnyObject] = [:]
            userInfo[NSLocalizedDescriptionKey] = "Failed while saving file"
            let error = NSError(domain: "[FileCenterDownloadable]", code: 500, userInfo: userInfo)
            dispatch_sync(dispatch_get_main_queue(), {
                self.failure?(error: error)
            })
        }
    }
}
