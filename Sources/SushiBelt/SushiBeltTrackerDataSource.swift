//
//  SushiBeltTrackerDataSource.swift
//  SushiBelt
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol SushiBeltTrackerDataSource: AnyObject {
  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect
  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat
}
