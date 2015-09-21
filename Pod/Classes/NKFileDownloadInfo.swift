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
    public var downloadRatio:Float = 0
    
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
        setValue(1, forKey: "downloadRatio")
        let folderURL = downloadFileURL.URLByDeletingLastPathComponent!
        if !fm.fileExistsAtPath(folderURL.path!)
        {
            do {
                try fm.createDirectoryAtURL(folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.description)
            }
        }
        if fm.fileExistsAtPath(downloadFileURL.path!)
        {
            do {
                try fm.removeItemAtURL(downloadFileURL)
            } catch let error as NSError {
                print(error.description)
            }
        }
        
        do {
            try fm.moveItemAtURL(location, toURL:downloadFileURL)
            NSLog("File successfully moved to \(downloadFileURL.path)")
        } catch let error as NSError {
            print(error.description)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
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
        setValue(Float(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)), forKey: "downloadRatio")
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