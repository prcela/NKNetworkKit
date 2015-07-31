# NKNetworkKit

[![CI Status](http://img.shields.io/travis/prcela/NKNetworkKit.svg?style=flat)](https://travis-ci.org/prcela/NKNetworkKit)
[![Version](https://img.shields.io/cocoapods/v/NKNetworkKit.svg?style=flat)](http://cocoapods.org/pods/NKNetworkKit)
[![License](https://img.shields.io/cocoapods/l/NKNetworkKit.svg?style=flat)](http://cocoapods.org/pods/NKNetworkKit)
[![Platform](https://img.shields.io/cocoapods/p/NKNetworkKit.svg?style=flat)](http://cocoapods.org/pods/NKNetworkKit)

## Basic usage

NetworkKit is the swift library that hides some complexity while doing network request.

Simple request:

```swift
	let request = NKWebRequest(host: "http://ip.jsontest.com", path: "")
	NKProcessor.process(request)
```

NKProcessor is adding request to operation queue and processing it asynchronously.

To handle the response, add these closures:

```swift
        NKProcessor.process(request,
            success: {object in
                let result = (object as! NKWebResponse).parsedJsonObject() as! NSDictionary
                NSLog("response: \(result)")
            },
            failure: nil,
            finish: nil)
```

Post some json data:

```swift
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
```

Or, download a file:

```swift
        let url = NSURL(string: "http://www.virtualmechanics.com/support/tutorials-spinner/Simple.pdf")
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let downloadPath = documentsPath.stringByAppendingPathComponent("simple.pdf")
        NKProcessor.startOrResumeDownloadTaskWithURL(url!, downloadPath: downloadPath, delegateQueue: nil)
```


## Requirements

## Installation

NKNetworkKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NKNetworkKit"
```

## Author

prcela, kresimir.prcela@gmail.com

## License

NKNetworkKit is available under the MIT license. See the LICENSE file for more info.
