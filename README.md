<img src="https://github.com/daangn/SushiBelt/blob/master/screenshots/logo.png" />

[![Version](https://img.shields.io/cocoapods/v/SushiBelt.svg?style=flat)](https://cocoapods.org/pods/SushiBelt)
[![License](https://img.shields.io/cocoapods/l/SushiBelt.svg?style=flat)](https://cocoapods.org/pods/SushiBelt)
[![Platform](https://img.shields.io/cocoapods/p/SushiBelt.svg?style=flat)](https://cocoapods.org/pods/SushiBelt)

## Basic Concept
The SushiBelt can be used to measure exposure according to the ratio for all views on the UIScrollView.

There are many characteristics of SushiBelt.

First of all, The impression ratio can be set differently for each UIView.

<img src="https://github.com/daangn/SushiBelt/blob/master/screenshots/objective_ratio.png" />

In the context of online advertising, An impression is when an ad is fetched from its source, and is countable. Whether the ad is clicked is not taken into account. Each time an ad is fetched, it is counted as one impression. 

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

### 1. Create a SushiBeltTracker

```swift
let tracker = SushiBeltTracker()

tracker.delegate = someObject
tracker.dataSource = someObject
tracker.scrollView = someScrollView
```


### 2. Inherits a SushiBeltTrackerDataSource
```swift
extension SomeObject: SushiBeltTrackerDataSource {
  
  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return CGRect(...) // tracking area rect
  }
  
  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    return 0.0 // default is zero, return visible ratio for item
  }
}
```

### 3. Inherits a SushiBeltTrackerDelegate 
```swift
extension SomeObject: SushiBeltTrackerDelegate {
  
  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    // begin tracking
  }
  
  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    // did end tracking
  }
}
```

## Advanced

### Custom Identifier
If you cannot use identifier base on index or IndexPath, you can make a custom identifier with SushiBeltTrackerIdentifier!
```swift
struct SomeData: SushiBeltTrackerIdentifier {

  let id: Int

  var var trackingIdentifer: String { 
    return "SomeData-\(id)"
  }
}
```

### SushiBeltTrackerItemDiffChecker
Default sushiBeltTrackerItem diff checker will update frameInWindow(CGRect) each overlaped items. also, it will decides ended items too. If you wanna to hook a diff mechanism then you can make a custom diff checker with SushiBeltTrackerItemDiffChecker interface.

```swift
final class CustomSushiBeltTrackerItemDiffChecker: SushiBeltTrackerItemDiffChecker { ... }
```

and you can injects a custom diff checker at making a SushiBeltTracker constructor.

```swift
let tracker = SushiBeltTracker(
 trackerItemDiffChecker: CustomSushiBeltTrackerItemDiffChecker()
)
```

### VisibleRatioCalculator
Default visible ratio clculator will calculate with CGRect.intersection with scrollDirection. If you wanna make a custom visible ratio calculation logics. you can make a custom visible ratio calculator with SushiBeltTrackerItemDiffChecker interface. you just inherts it!

```swift
final class CustomVisibleRatioCalculator: VisibleRatioCalculator { ... }
```

and you can injects a custom visible ratio calculator at making a SushiBeltTracker constructor.

```swift
let tracker = SushiBeltTracker(
 visibleRatioCalculator: CustomVisibleRatioCalculator()
)
```

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
