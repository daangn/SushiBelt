//
//  ViewVisibleTrackerDelegate.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol ViewVisibleTrackerDelegate: AnyObject {
  func willBeginTracking(_ tracker: ViewVisibleTracker, item: ViewVisibleTrackingItem)
  func didEndTracking(_ tracker: ViewVisibleTracker, item: ViewVisibleTrackingItem)
}
