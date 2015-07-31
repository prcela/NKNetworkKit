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
        let request = NKWebRequest(host: "http://ip.jsontest.com", path: "")
        NKProcessor.process(request)
        
        // same request but now with success handler
        NKProcessor.process(request,
            success: {object in
                let result = (object as! NKWebResponse).parsedJsonObject() as! NSDictionary
                NSLog("response: \(result)")
            },
            failure: nil,
            finish: nil)
        
        // post some json object
        let data = NSJSONSerialization.dataWithJSONObject(["text":"example_text"],
            options:NSJSONWritingOptions(0),
            error:nil)

        let postRequest = NKWebRequest(host: "http://httpbin.org", path: "post", jsonData: data!)
        
        NSLog("Sending %@", postRequest.description)
        
        NKProcessor.process(postRequest,
            success: {object in
                let result = (object as! NKWebResponse).parsedJsonObject() as! NSDictionary
                NSLog("Result of simple JSON post as dictionary: \(result)")
            },
            failure: nil, finish: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

