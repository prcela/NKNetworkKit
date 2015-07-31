//
//  NKWebResponse.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//

import UIKit

public class NKWebResponse: NSObject
{
    var statusCode: Int = 0
    var data: NSData?
    
    public func isOk() -> Bool
    {
        return statusCode == 200
    }
    
    public func parsedJsonObject() -> AnyObject?
    {
        if let data = self.data
        {
            return NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.MutableContainers,
                error: nil)
        }
        else
        {
            return nil
        }
    }
}
