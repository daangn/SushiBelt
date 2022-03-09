//
//  SushiBeltTrackerDelegateSpy.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
@testable import SushiBelt

final class SushiBeltTrackerDelegateSpy: SushiBeltTrackerDelegate {
  
  var willBeginTrackingItem: SushiBeltTrackerItem?
  
  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    self.willBeginTrackingItem = item
  }
  
  var didEndTrackingItem: SushiBeltTrackerItem?
  
  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    self.didEndTrackingItem = item
  }
  
}
