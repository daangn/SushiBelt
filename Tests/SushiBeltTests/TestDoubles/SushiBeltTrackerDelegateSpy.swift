//
//  SushiBeltTrackerDelegateSpy.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
@testable import SushiBelt

final class SushiBeltTrackerDelegateSpy: SushiBeltTrackerDelegate {
  
  var willBeginTrackingItems: [SushiBeltTrackerItem] = []
  
  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    self.willBeginTrackingItems.append(item)
  }

  var didEnterItems: [SushiBeltTrackerItem] = []

  func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    self.didEnterItems.append(item)
  }

  var didEndTrackingItems: [SushiBeltTrackerItem] = []

  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    self.didEndTrackingItems.append(item)
  }

  var didExitItems: [SushiBeltTrackerItem] = []

  func didExit(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    self.didExitItems.append(item)
  }

}
