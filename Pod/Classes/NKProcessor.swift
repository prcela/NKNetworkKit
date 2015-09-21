//
//  NKProcessor.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//


// Web request processor
public class NKProcessor: NSObject {
    
    static var defaultConfiguration = NKProcessor.defaultSessionConfiguration()
    
    class func defaultSessionConfiguration() -> NSURLSessionConfiguration
    {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 30
        return sessionConfig
    }
    
    public class func process(request: NKRequest,
        success: ((NKResponse) -> Void)? = nil,
        failure: ((NSError) -> Void)? = nil,
        finish: (() -> Void)? = nil)
    {
        var session: NSURLSession
        
        if (request.queue != nil || request.delegate != nil)
        {
            session = NSURLSession(configuration: defaultConfiguration, delegate: request.delegate, delegateQueue: request.queue)
        }
        else
        {
            session = NSURLSession(configuration: defaultConfiguration)
        }
        
        processDataRequest(request, session: session, success: success, failure: failure, finish: finish)
    }
    
    class func processDataRequest(request: NKRequest, session: NSURLSession,
        success: ((NKResponse) -> Void)? = nil,
        failure: ((NSError) -> Void)? = nil,
        finish: (() -> Void)? = nil)
    {
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let httpResp = response as? NSHTTPURLResponse

            let webResponse = NKResponse()
            webResponse.data = data
            webResponse.statusCode = httpResp?.statusCode ?? 0

            
            NSLog("Finished request \(request.URL!) with status: \(webResponse.statusCode)")
            
#if DEBUG
            // Dump small responses into console
            if (data.length < 1000)
            {
                if let strData = NSString(data: data, encoding: NSUTF8StringEncoding) where strData.length > 0
                {
                    NSLog("%@", strData)
                }
            }
            else
            {
                NSLog("Response data is large... Wont dump it.");
            }
#endif
            
            if (error != nil)
            {
                let reqError = NKRequestError(error: error!, timestamp: NSDate(), url: request.URL!, statusCode: webResponse.statusCode)
                
                NSLog("%@", error!.localizedDescription)
                
                
                failure?(error!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    NKProcessorInfo.shared.errors.append(reqError)
                    NSNotificationCenter.defaultCenter().postNotificationName(NKNotificationRequestError,
                        object:reqError)
                    })
            }
            else if (webResponse.statusCode >= 400 && webResponse.statusCode != 401)
            {
                let reqError = NKRequestError(error: error!, timestamp: NSDate(), url: request.URL!, statusCode: webResponse.statusCode)
                
                failure?(error!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    NKProcessorInfo.shared.errors.append(reqError)
                    NSNotificationCenter.defaultCenter().postNotificationName(NKNotificationRequestError,
                        object:reqError)
                    })
            }
            else
            {
                success?(webResponse)
            }
            
            if let notificationName = request.notificationName
            {
                dispatch_async(dispatch_get_main_queue(), {
                    let object = request.notificationObject ?? webResponse
                    NSNotificationCenter.defaultCenter().postNotificationName(notificationName,
                        object: object)
                    })

            }
            
            finish?()
        })
        
        task.resume()
    }
    
    // Start or resume task.
    public class func startOrResumeDownloadTaskWithURL(url: NSURL, downloadFileURL:NSURL, delegateQueue queue:NSOperationQueue?)
    {
        // if file is already downloading
        if let fdi = NKProcessorInfo.shared.infoForUrl(url)
        {
            let session = NSURLSession(configuration: defaultConfiguration, delegate: fdi, delegateQueue: queue)
            fdi.downloadFileURL = downloadFileURL
            switch fdi.task!.state
            {
            case .Suspended:
                // resume
                fdi.task!.resume()
            case .Canceling:
                // create new task with resume data
                if let resumeData = fdi.resumeData
                {
                    fdi.task = session.downloadTaskWithResumeData(resumeData)
                    fdi.task!.resume()
                }
                else
                {
                    fdi.task = session.downloadTaskWithURL(url)
                    fdi.task!.resume()
                }
                
            default:
                NSLog("Download task is already completed or running")
            }
        }
        else
        {
            // create new download task with given url
            let fdi = NKFileDownloadInfo(url: url, downloadFileURL: downloadFileURL)
            let session = NSURLSession(configuration: defaultConfiguration, delegate: fdi, delegateQueue: queue)
            fdi.task = session.downloadTaskWithURL(url)
            NKProcessorInfo.shared.downloads.append(fdi)
            fdi.task.resume()
        }
    }
}
