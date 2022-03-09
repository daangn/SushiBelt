//
//  VisibleRatioCalculatorSpy.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

@testable import SushiBelt

final class VisibleRatioCalculatorSpy: VisibleRatioCalculator {
  
  var visibleRatioStub: CGFloat?
  var visibleRatioItem: SushiBeltTrackerItem?
  var visibleRatioTrackingRect: CGRect?
  var visibleRatioScrollDirection: SushiBeltTrackerScrollDirection?
  
  func visibleRatio(
    item: SushiBeltTrackerItem,
    trackingRect: CGRect,
    scrollDirection: SushiBeltTrackerScrollDirection?
  ) -> CGFloat? {
    self.visibleRatioItem = item
    self.visibleRatioTrackingRect = trackingRect
    self.visibleRatioScrollDirection = scrollDirection
    return visibleRatioStub
  }
}
