//
//   SushiBeltTrackerDelegate.swift
//  SushiBelt
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol  SushiBeltTrackerDelegate: AnyObject {
  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)
  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem)
}
