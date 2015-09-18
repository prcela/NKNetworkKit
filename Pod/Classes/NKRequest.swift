//
//  NKWebRequest.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

public class NKRequest: NSMutableURLRequest
{
    public var notificationName: String?
    public var notificationObject: NSObject?
    public var queue: NSOperationQueue?
    public var delegate: NSURLSessionDelegate?
    
    
    public convenience init(host:String, path:String? = nil, params:String? = nil, method:String? = nil)
    {

        var url = NSURL(string: host)
        if path != nil
        {
            url = url?.URLByAppendingPathComponent(path!)
        }

        self.init(URL: url!)
        
        if method != nil
        {
            HTTPMethod = method!
            setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        if params != nil
        {
            let postData = params!.dataUsingEncoding(NSUTF8StringEncoding)
            let postLength = "\(postData!.length)"
            setValue(postLength, forHTTPHeaderField:"Content-Length")
            HTTPBody = postData
        }
    }
    
    public convenience init(host:String, path:String? = nil, postJsonData:NSData)
    {
        var url = NSURL(string: host)
        if path != nil
        {
            url = url?.URLByAppendingPathComponent(path!)
        }
        self.init(URL: url!)
        
        HTTPMethod = "POST"
        setValue("application/json", forHTTPHeaderField:"Accept")
        setValue("application/json", forHTTPHeaderField:"Content-Type")
        setValue("\(postJsonData.length)", forHTTPHeaderField:"Content-Length")
        HTTPBody = postJsonData
    }
}