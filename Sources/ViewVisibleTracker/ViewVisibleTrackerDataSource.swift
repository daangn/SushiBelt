//
//  ViewVisibleTrackerDataSource.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol ViewVisibleTrackerDataSource: AnyObject {
  func trackingRect(_ tracker: ViewVisibleTracker) -> CGRect
  func visibleRatioForItem(_ tracker: ViewVisibleTracker, item: ViewVisibleTrackingItem) -> CGFloat
}
