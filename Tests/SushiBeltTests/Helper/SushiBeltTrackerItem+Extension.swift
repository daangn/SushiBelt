//
//  SushiBeltTrackerItem+Extension.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

@testable import SushiBelt

// MARK: - SushiBeltTrackerItem extension

extension SushiBeltTrackerItem {
  
  func frameInWindow(_ frame: CGRect) -> SushiBeltTrackerItem {
    var mutableItem = self
    mutableItem.rect = .init(frame: frame)
    return mutableItem
  }
  
  func tracked() -> SushiBeltTrackerItem {
    var mutableItem = self
    mutableItem.isTracked = true
    return mutableItem
  }
  
}
