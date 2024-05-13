//
//  SushiBeltTrackerItem+Extension.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation

// MARK: - Debugging

extension SushiBeltTrackerItem {
  
  func currentVisibleRatioPercentageString() -> String {
    return String(
      format: "%.2f",
      self.currentVisibleRatio * 100
    ) + "%"
  }
  
  func objectiveVisibleRatioPercentageString() -> String {
    return String(
      format: "%.2f",
      self.objectiveVisibleRatio * 100
    ) + "%"
  }
  
  func defaultDescirption() -> String {
    return "\(self.currentVisibleRatioPercentageString())\nObjective: \(self.objectiveVisibleRatioPercentageString())"
  }
  
}
