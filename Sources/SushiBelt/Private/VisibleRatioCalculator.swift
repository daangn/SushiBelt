//
//  VisibleRatioCalculator.swift
//  SushiBelt
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

public protocol VisibleRatioCalculator {
  
  func visibleRatio(
    item: SushiBeltTrackerItem,
    trackingRect: CGRect,
    scrollDirection: SushiBeltTrackerScrollDirection?
  ) -> CGFloat?
}

public struct DefaultVisibleRatioCalculator: VisibleRatioCalculator {
  
  public func visibleRatio(
    item: SushiBeltTrackerItem,
    trackingRect: CGRect,
    scrollDirection: SushiBeltTrackerScrollDirection?
  ) -> CGFloat? {
    let visibleRect = trackingRect.intersection(item.rect.frameInWindow)
    let itemRectPixels = item.rect.frameInWindow.height * item.rect.frameInWindow.width
    let visiblePixels = visibleRect.height * visibleRect.width
    return visiblePixels / itemRectPixels
  }
}
