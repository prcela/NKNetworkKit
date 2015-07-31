//
//  NKInfo.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

import UIKit
import Reachability

let NKNotificationWebRequestError = "NotificationWebRequestError"


public class NKProcessorInfo: NSObject {
    static var shared = NKProcessorInfo()
    var errors:[NKWebRequestError] = []
    var downloads:[NKFileDownloadInfo] = []
    
    override init()
    {
        super.init()

        let reach = Reachability.reachabilityForInternetConnection()
        
        reach.reachableBlock = {(reach) in
            
            
            for fdi in self.downloads
            {
                if (fdi.task.state == .Suspended || fdi.task.state == .Completed)
                {
                    let session = NSURLSession(configuration: NKProcessor.defaultConfiguration,
                        delegate: fdi, delegateQueue: nil)

                    NSLog("Resuming download: \(fdi.url)")
                    if fdi.resumeData != nil
                    {
                        fdi.task = session.downloadTaskWithResumeData(fdi.resumeData!)
                    }
                    else
                    {
                        fdi.task = session.downloadTaskWithURL(fdi.url)
                    }
                    fdi.task.resume()
                }
            }
        }
        
        reach.startNotifier()


    }
    
    func infoForUrl(url:NSURL) -> NKFileDownloadInfo?
    {
        for fdi in downloads
        {
            if fdi.url.absoluteString == url.absoluteString
            {
                return fdi
            }
        }
        return nil
    }
    
    func infoForTask(task: NSURLSessionDownloadTask) -> (Int,NKFileDownloadInfo)?
    {
        for (idx,fdi) in enumerate(downloads)
        {
            if fdi.task == task
            {
                return (idx,fdi)
            }
        }
        return nil
    }
}
