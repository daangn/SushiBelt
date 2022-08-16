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
    
    guard let scrollDirection = scrollDirection else {
      return nil
    }
    
    let visibleRect = trackingRect.intersection(item.rect.frameInWindow)
    
    switch scrollDirection {
    case .up, .down:
      return min(1.0, visibleRect.height / item.rect.frameInWindow.height)
    case .left, .right:
      return min(1.0, visibleRect.width / item.rect.frameInWindow.width)
    }
  }
}
