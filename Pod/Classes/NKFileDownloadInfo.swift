//
//  NKFileDownloadInfo.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

// Global constants for notifications
public let NKNotificationDownloadTaskDidFinish = "NKNotificationDownloadTaskDidFinish"
public let NKNotificationDownloadTaskDidResumeData = "NKNotificationDownloadTaskDidResumeData"

// MARK: - File download info
public class NKFileDownloadInfo: NSObject {
    public var url: NSURL
    public var task: NSURLSessionDownloadTask!
    public var resumeData: NSData?
    public var downloadFileURL: NSURL
    public var downloadRatio:Float = 0 // observable value
    public var finished = false // observable value
    
    public static let keyDownloadRatio = "downloadRatio"
    public static let keyFinished = "finished"
    
    public init(url:NSURL, downloadFileURL: NSURL)
    {
        self.url = url
        self.downloadFileURL = downloadFileURL
        
        super.init()
    }
}

// MARK: - Session delegate
extension NKFileDownloadInfo: NSURLSessionDownloadDelegate
{
    // didFinishDownloadingToURL
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    {
        NSLog("Did finish download to url: %@", location)
        
        let fm = NSFileManager.defaultManager()
        setValue(1, forKey: NKFileDownloadInfo.keyDownloadRatio)
        let folderURL = downloadFileURL.URLByDeletingLastPathComponent!
        do {
            if !fm.fileExistsAtPath(folderURL.path!)
            {
                try fm.createDirectoryAtURL(folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            if fm.fileExistsAtPath(downloadFileURL.path!)
            {
                try fm.removeItemAtURL(downloadFileURL)
            }
            try fm.moveItemAtURL(location, toURL:downloadFileURL)
            NSLog("File successfully moved to \(downloadFileURL.path)")
            
        } catch let error as NSError {
            print(error.description)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.setValue(true, forKey: NKFileDownloadInfo.keyFinished)
            if let idx = NKProcessorInfo.shared.downloads.indexOf(self) {
                NKProcessorInfo.shared.downloads.removeAtIndex(idx)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NKNotificationDownloadTaskDidFinish,
                object:self)
        }
    }


    // didWriteData
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        setValue(Float(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)), forKey: NKFileDownloadInfo.keyDownloadRatio)
    }
    
    // didResumeAtOffset
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    {
        NSLog("Did resume at offset %lld", fileOffset)
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(NKNotificationDownloadTaskDidResumeData,
                object:downloadTask.taskIdentifier)
        }
    }
    
    // didCompleteWithError
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if error != nil
        {
            NSLog("Did complete with error: \(error!.description)")
            if let resumeData = error!.userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
            {
                self.resumeData = resumeData
            }
        }
    }
}