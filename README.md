<img src="https://github.com/daangn/SushiBelt/blob/master/screenshots/logo.png" />

[![Version](https://img.shields.io/cocoapods/v/SushiBelt.svg?style=flat)](https://cocoapods.org/pods/SushiBelt)
[![License](https://img.shields.io/cocoapods/l/SushiBelt.svg?style=flat)](https://cocoapods.org/pods/SushiBelt)
[![Platform](https://img.shields.io/cocoapods/p/SushiBelt.svg?style=flat)](https://cocoapods.org/pods/SushiBelt)

## Basic Concept
The SushiBelt can be used to measure exposure according to the ratio for all views on the UIScrollView.

There are many characteristics of SushiBelt.

First of all, The impression ratio can be set differently for each UIView.

<img src="https://github.com/daangn/SushiBelt/blob/master/screenshots/objective_ratio.png" />

In the context of online advertisingm An impression is when an ad is fetched from its source, and is countable. Whether the ad is clicked is not taken into account. Each time an ad is fetched, it is counted as one impression. 

In Summary, SushiBelt can measure the impression according to the objective visible ratio for each UIView.

<img src="https://github.com/daangn/SushiBelt/blob/master/screenshots/ratio.png" />

- Green Area means a measurable range.
- Red line means a calculated visible ratio from SushiBelt.
- Blue line means a objective visible ratio for impression.

Also, SushiBelt calculates visible ratio as the scroll direction changes.

<img src="https://github.com/daangn/SushiBelt/blob/master/screenshots/scroll_direction.png" />

## Features

- [x] Support a measurement of exposure ratio for each view.
- [x] Support a various item identifiers such as integer index, IndexPath, and user-defined identifier.
- [x] Visibility Debugger.

## Basic usages

👨‍🔧 Under construction 🧑‍🔧

## Advanced

👨‍🔧 Under construction 🧑‍🔧

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 11.0

## Installation

### CocoaPods

SushiBelt is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SushiBelt'
```

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding SushiBelt as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com:daangn/SushiBelt.git", .upToNextMajor(from: "0.1.0"))
]
```

## Author

- [Geektree0101](https://www.github.com/Geektree0101)
- [ElonPark](https://www.github.com/ElonPark)
- [jinsu3758](https://www.github.com/jinsu3758)

## License

SushiBelt is available under the MIT license. See the LICENSE file for more info.
