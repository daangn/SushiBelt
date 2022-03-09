//
//  SushiBeltTrackerItemDiffResult.swift
//  SushiBelt
//
//  Created by david on 2022/03/09.
//

import Foundation

public struct SushiBeltTrackerItemDiffResult {
  public let calculationTargetedItems: Set<SushiBeltTrackerItem>
  public let endedItems: Set<SushiBeltTrackerItem>
  
  public init(
    calculationTargetedItems: Set<SushiBeltTrackerItem>,
    endedItems: Set<SushiBeltTrackerItem>
  ) {
    self.calculationTargetedItems = calculationTargetedItems
    self.endedItems = endedItems
  }
}
