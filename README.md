# PKSwiftSocket

[![CI Status](http://img.shields.io/travis/Prateek Kansara/PKSwiftSocket.svg?style=flat)](https://travis-ci.org/Prateek Kansara/PKSwiftSocket)
[![Version](https://img.shields.io/cocoapods/v/PKSwiftSocket.svg?style=flat)](http://cocoapods.org/pods/PKSwiftSocket)
[![License](https://img.shields.io/cocoapods/l/PKSwiftSocket.svg?style=flat)](http://cocoapods.org/pods/PKSwiftSocket)
[![Platform](https://img.shields.io/cocoapods/p/PKSwiftSocket.svg?style=flat)](http://cocoapods.org/pods/PKSwiftSocket)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8.0+ 
* Xcode 7.3.1+

## Installation

PKSwiftSocket is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PKSwiftSocket"
```

##Usage

```ruby

    // Initialize Socket object
    let pksocketobj : PKSocket = PKSocket(lAddress : address, lPort : port)

    // Handle connection with blocks
    pksocketobj.handleConnection({

        (Data : String?) in
        // Handle response data
            print("Response data : \(Data)")
        }, Error: {
            (errorString : String) in
            // Error when connection to address
            print("Error : \(errorString)")
    })

    /**
    Send data to address
    */
    pksocketobj.sendDataToStream("")
```
## Author

Prateek Kansara, prateek@kansara.in

## License

PKSwiftSocket is available under the MIT license. See the LICENSE file for more info.
