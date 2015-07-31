//
//  NKWebRequestError.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

import UIKit

public class NKWebRequestError: NSObject
{
    var timestamp: NSDate
    var url: NSURL
    var error: NSError?
    var statusCode: Int
    
    init(error:NSError,timestamp:NSDate,url:NSURL,statusCode:Int)
    {
        self.error = error
        self.timestamp = timestamp
        self.url = url
        self.statusCode = statusCode
        super.init()
    }
}
