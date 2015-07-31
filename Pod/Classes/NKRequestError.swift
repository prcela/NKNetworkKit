//
//  NKWebRequestError.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

public class NKRequestError: NSObject
{
    public var timestamp: NSDate
    public var url: NSURL
    public var error: NSError?
    public var statusCode: Int
    
    public init(error:NSError,timestamp:NSDate,url:NSURL,statusCode:Int)
    {
        self.error = error
        self.timestamp = timestamp
        self.url = url
        self.statusCode = statusCode
        super.init()
    }
}
