//
//   SushiBeltTrackerDelegate.swift
//  SushiBelt
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol SushiBeltTrackerDelegate: AnyObject {
  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)
  func didTrack(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)
  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)

  /// Called when an item with `tracksDismiss == true` stops meeting the
  /// visibility threshold while still being tracked. This is the symmetric
  /// counterpart to `didTrack`, fired on down-crossings of the threshold.
  ///
  /// Default implementation is a no-op, so existing delegate conformances
  /// compile without changes. Items registered with `tracksDismiss == false`
  /// (the default) never trigger this callback.
  func didDismiss(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)
}

extension SushiBeltTrackerDelegate {
  public func didDismiss(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {}
}
