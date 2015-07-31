# NKNetworkKit

[![CI Status](http://img.shields.io/travis/prcela/NKNetworkKit.svg?style=flat)](https://travis-ci.org/prcela/NKNetworkKit)
[![Version](https://img.shields.io/cocoapods/v/NKNetworkKit.svg?style=flat)](http://cocoapods.org/pods/NKNetworkKit)
[![License](https://img.shields.io/cocoapods/l/NKNetworkKit.svg?style=flat)](http://cocoapods.org/pods/NKNetworkKit)
[![Platform](https://img.shields.io/cocoapods/p/NKNetworkKit.svg?style=flat)](http://cocoapods.org/pods/NKNetworkKit)

**NetworkKit is the swift library that hides some complexity of doing network request.
**

## Features

 - Easy syntax for sending request
 - Handling web response in place with closures
 - Posting json data
 - Mechanism for starting and automatic resuming of file download
 - Observe downloading progress ratio

## Basic usage

Simple request:

```swift
	let request = NKWebRequest(host: "http://ip.jsontest.com")
	NKProcessor.process(request)
```

NKProcessor is adding request to operation queue and processing it asynchronously.

To handle the response, add these closures:

```swift
    NKProcessor.process(request,
        success: {response in
            let result = response.parsedJsonObject() as! NSDictionary
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
    let postRequest = NKWebRequest(host: "http://httpbin.org", path: "post", postJsonData: data!)
    NSLog("Sending %@", postRequest.description)
    NKProcessor.process(postRequest,
        success: {response in
            let result = response.parsedJsonObject() as! NSDictionary
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

Observe the event of completed download:

```swift
    let nc = NSNotificationCenter.defaultCenter()
    nc.addObserver(self, selector: "downloadTaskDidFinish:", name: NKNotificationDownloadTaskDidFinish, object: nil)


    func downloadTaskDidFinish(notification: NSNotification)
    {
        let fdi = notification.object as! NKFileDownloadInfo
    }
```

Inside the info object there is the url of the completed download.

Behind the scene, NKProcessor is keeping session, data and current state of all currently downloading tasks (files). 
If network connection becomes offline and online again, the processor will automatically continue with file downloading.

At any moment you can check the progress ratio and task status of downloading file:

```swift
    let fdi = NKProcessorInfo.shared.infoForUrl(url)
```

Note that you can use your own NSOperationQueue when you are willing to download too many files. Your queue is defining rules of max concurent downloads.

One more thing, connect the download progress ratio with your custom class (i.e. derive MyProgressView from UIProgressView):

```swift
    if let dfi = NKProcessorInfo.shared.infoForUrl(url!)
    {
        dfi.addObserver(myProgressView, forKeyPath: "downloadRatio", options: NSKeyValueObservingOptions.allZeros, context: nil)
    }

    class MyProgressView: UIProgressView
    {
        override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>)
        {
            let fdi = object as! NKFileDownloadInfo
            dispatch_async(dispatch_get_main_queue()) {
                self.setProgress(fdi.downloadRatio, animated: false)
            }
        }
    }
```

## Requirements

Swift, minimim iOS 8.0

## Installation

NKNetworkKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NKNetworkKit"
```

## Author

Krešimir Prcela, kresimir.prcela@gmail.com

## License

NKNetworkKit is available under the MIT license. See the LICENSE file for more info.
