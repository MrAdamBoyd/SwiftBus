# SwiftBus
Interface for NextBus API written in Swift

[![CI Status](http://img.shields.io/travis/Adam Boyd/SwiftBus.svg?style=flat)](https://travis-ci.org/Adam Boyd/SwiftBus)
[![Version](https://img.shields.io/cocoapods/v/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)
[![License](https://img.shields.io/cocoapods/l/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)
[![Platform](https://img.shields.io/cocoapods/p/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
SwiftBus will run on iOS 8 and above, and Mac OS X 10.9 Mavericks and above. If you are using or targeting iOS 9 and OS X 10.11 and above, you also need to have NSAppTransportSecurity working with `nextbus.com`.

## NSAppTransportSecurity
Starting in iOS 9 and OS X 10.11, Apple is restricting the use of `http` addresses unless otherwise specified. Because NextBus's website is currently http-only, NSAppTransportSecurity needs to be enabled for `nextbus.com`. Add this to your `Info.plist`:


<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>nextbus.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.1</string>
        </dict>
    </dict>
</dict>

## Installation

SwiftBus is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftBus"
```

## Author
My name is Adam Boyd.

Your best bet to contact me is on Twitter. [@MrAdamBoyd](https://twitter.com/MrAdamBoyd)

My website is [adamjboyd.com](http://www.adamjboyd.com).

## License

SwiftBus is available under the MIT license. See the LICENSE file for more info.
