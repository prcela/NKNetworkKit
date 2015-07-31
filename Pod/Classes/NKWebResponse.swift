//
//  NKWebResponse.swift
//  NetworkKit
//
//  Created by Kresimir Prcela on 15/07/15.
//  Copyright (c) 2015 prcela. All rights reserved.
//


public class NKWebResponse: NSObject
{
    public var statusCode: Int = 0
    public var data: NSData?
    
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
