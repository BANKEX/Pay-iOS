# BANKEX Wallet - Ethereum Wallet for iOS
![](https://github.com/BANKEX/BankexWalletIOS/blob/fix/Readme/Badge/%20bankex.png)

<p align="center">
 <a href="https://itunes.apple.com/ru/app/bankex-pay/id1411403963?l=en&mt=8"><img src="/Badge/appStore.svg"/></a>
 </p>
 
 <br>
 
[![Swift](https://img.shields.io/badge/Swift-4.0-blue.svg)](https://swift.org/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2B9.0-purple.svg)](https://developer.apple.com/swift)
[![Build Status](https://travis-ci.org/BANKEX/BankexWalletIOS.svg?branch=develop)](https://travis-ci.org/BANKEX/BankexWalletIOS)

<br>
Welcome to BANKEX's open source iOS app!



## Getting Started

1. [Download](https://developer.apple.com/xcode/download/) the Xcode 9 release.
1. Clone this repository.

## Contributing

We intend for this project to be an educational resource: we are excited to
share our wins, mistakes, and methodology of iOS development as we work
in the open. Our primary focus is to continue improving the app for our users in
line with our roadmap.

The best way to submit feedback and report bugs is to open a GitHub issue.
Please be sure to include your operating system, device, version number, and
steps to reproduce reported bugs. Keep in mind that all participants will be
expected to follow our code of conduct.

## Code of Conduct

We aim to share our knowledge and findings as we work daily to improve our
product, for our community, in a safe and open space. We work as we live, as
kind and considerate human beings who learn and grow from giving and receiving
positive, constructive feedback. We reserve the right to delete or ban any
behavior violating this base foundation of respect.

## Publishing your own pull request
If you want to publish your own pull request, you might want to ask us before to avoid doing similar work.

## Requirements
- iOS 9.0+ SDK
- Xcode 9 or later

## CocoaPods
If you want to add you own pods or update existing, you need to install cocoapods.

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```


To integrate any pod into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'BankexWallet' do
#add your new pod here
pod 'web3swift'
end
```

Then, run the following command:

```bash
$ pod install
```

## Details
More details (architecture, environments, tests, tools...) can be found on the [wiki](https://github.com/BANKEX/BankexWalletIOS/wiki).

## Change-log

A brief summary of each Lovely release can be found on the [releases](https://github.com/BANKEX/BankexWalletIOS/releases).
