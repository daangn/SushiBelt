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

  /// Called when an item's visible ratio crosses up to meet the threshold
  /// (`isTracked` becomes `true`). For sticky items (`tracksExit == false`)
  /// this fires once; for symmetric items (`tracksExit == true`) it fires
  /// again on every up-crossing after a prior `didExit`.
  func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)

  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)

  /// Called when an item with `tracksExit == true` stops meeting the
  /// visibility threshold while still being tracked. This is the symmetric
  /// counterpart to `didEnter`, fired on down-crossings of the threshold.
  ///
  /// Default implementation is a no-op, so existing delegate conformances
  /// compile without changes. Items registered with `tracksExit == false`
  /// (the default) never trigger this callback.
  func didExit(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)
}

extension SushiBeltTrackerDelegate {
  public func didExit(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {}
}
