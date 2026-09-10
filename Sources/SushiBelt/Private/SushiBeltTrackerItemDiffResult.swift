//
//  SushiBeltTrackerItemDiffResult.swift
//  SushiBelt
//
//  Created by david on 2022/03/09.
//

import Foundation

struct SushiBeltTrackerItemDiffResult {
  let calculationTargetedItems: Set<SushiBeltTrackerItem>
  let newItems: Set<SushiBeltTrackerItem>
  let endedItems: Set<SushiBeltTrackerItem>
  
  init(
    calculationTargetedItems: Set<SushiBeltTrackerItem>,
    newItems: Set<SushiBeltTrackerItem>,
    endedItems: Set<SushiBeltTrackerItem>
  ) {
    self.calculationTargetedItems = calculationTargetedItems
    self.newItems = newItems
    self.endedItems = endedItems
  }
}
