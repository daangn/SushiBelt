//
//  VisibleRatioCalculator.swift
//  SushiBelt
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

protocol VisibleRatioCalculator {
  
  func visibleRatio(
    item: SushiBeltTrackerItem,
    trackingRect: CGRect
  ) -> CGFloat?
}

struct DefaultVisibleRatioCalculator: VisibleRatioCalculator {
  
  func visibleRatio(
    item: SushiBeltTrackerItem,
    trackingRect: CGRect
  ) -> CGFloat? {
    let visibleRect = trackingRect.intersection(item.rect.frameInWindow)
    let itemRectPixels = item.rect.frameInWindow.height * item.rect.frameInWindow.width
    let visiblePixels = visibleRect.height * visibleRect.width
    return visiblePixels / itemRectPixels
  }
}
