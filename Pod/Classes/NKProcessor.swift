//
//  NKProcessor.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

import UIKit

public class NKProcessor: NSObject {
    static var defaultConfiguration = NKProcessor.defaultSessionConfiguration()
    
    class func defaultSessionConfiguration() -> NSURLSessionConfiguration
    {
        var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 30
        return sessionConfig
    }
    
    public class func process(request: NKWebRequest)
    {
        process(request, success: nil, failure: nil, finish: nil)
    }
    
    public class func process(request: NKWebRequest,
        success: ((NSObject) -> Void)?,
        failure: ((NSError) -> Void)?,
        finish: (() -> Void)?)
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
    
    class func processDataRequest(request: NKWebRequest, session: NSURLSession,
        success: ((NSObject) -> Void)?,
        failure: ((NSError) -> Void)?,
        finish: (() -> Void)?)
    {
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let httpResp = response as? NSHTTPURLResponse

            let webResponse = NKWebResponse()
            webResponse.data = data
            webResponse.statusCode = httpResp?.statusCode ?? 0

            
            NSLog("Finished request %@ with status: %ld", request.URL!, webResponse.statusCode)
            
#if DEBUG
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
                let webReqError = NKWebRequestError(error: error, timestamp: NSDate(), url: request.URL!, statusCode: webResponse.statusCode)
                
                NSLog("%@", error.localizedDescription)
                
                
                failure?(error)
                
                dispatch_async(dispatch_get_main_queue(), {
                    NKProcessorInfo.shared.errors.append(webReqError)
                    NSNotificationCenter.defaultCenter().postNotificationName(NKNotificationWebRequestError,
                        object:webReqError)
                    })
            }
            else if (webResponse.statusCode >= 400 && webResponse.statusCode != 401)
            {
                let webReqError = NKWebRequestError(error: error, timestamp: NSDate(), url: request.URL!, statusCode: webResponse.statusCode)
                
                failure?(error)
                
                dispatch_async(dispatch_get_main_queue(), {
                    NKProcessorInfo.shared.errors.append(webReqError)
                    NSNotificationCenter.defaultCenter().postNotificationName(NKNotificationWebRequestError,
                        object:webReqError)
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
    
    public class func startOrResumeDownloadTaskWithURL(url: NSURL, downloadPath:String, delegateQueue queue:NSOperationQueue?)
    {
        if let fdi = NKProcessorInfo.shared.infoForUrl(url)
        {
            let session = NSURLSession(configuration: defaultConfiguration, delegate: fdi, delegateQueue: queue)
            fdi.downloadFilePath = downloadPath
            switch fdi.task!.state
            {
            case .Suspended:
                // nastavi gdje je stao
                fdi.task!.resume()
            case .Canceling:
                // napravi novi task sa postojećim podacima
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
            
            
            let fdi = NKFileDownloadInfo(url: url, downloadFilePath: downloadPath)
            let session = NSURLSession(configuration: defaultConfiguration, delegate: fdi, delegateQueue: queue)
            fdi.task = session.downloadTaskWithURL(url)
            NKProcessorInfo.shared.downloads.append(fdi)
            fdi.task.resume()
        }
    }
}
