//
//  ViewController.swift
//  NKNetworkKit
//
//  Created by prcela on 07/31/2015.
//  Copyright (c) 2015 prcela. All rights reserved.
//

import UIKit
import NKNetworkKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // some simple request
        let request = NKRequest(host: "http://ip.jsontest.com")
        NKProcessor.process(request)
        
        // same request but now with success handler
        NKProcessor.process(request,
            success: {response in
                let result = response.parsedJsonObject() as! NSDictionary
                NSLog("response: \(result)")
            },
            failure: nil,
            finish: nil)
        
        // post some json object
        let data = NSJSONSerialization.dataWithJSONObject(["text":"example_text"],
            options:NSJSONWritingOptions(0),
            error:nil)

        let postRequest = NKRequest(host: "http://httpbin.org", path: "post", postJsonData: data!)
        
        NSLog("Sending %@", postRequest.description)
        
        NKProcessor.process(postRequest,
            success: {response in
                let result = response.parsedJsonObject() as! NSDictionary
                NSLog("Result of simple JSON post as dictionary: \(result)")
            },
            failure: nil, finish: nil)
        
        // download file
        let url = NSURL(string: "http://www.virtualmechanics.com/support/tutorials-spinner/Simple.pdf")
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let downloadPath = documentsPath.stringByAppendingPathComponent("simple.pdf")
        NKProcessor.startOrResumeDownloadTaskWithURL(url!, downloadPath: downloadPath, delegateQueue: nil)
    }
}

