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
  
  func visibleRatio(
    item: SushiBeltTrackerItem,
    trackingRect: CGRect
  ) -> CGFloat? {
    self.visibleRatioItem = item
    self.visibleRatioTrackingRect = trackingRect
    return visibleRatioStub
  }
}
