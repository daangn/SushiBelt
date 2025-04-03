//
//  SushiBeltTrackerItemDiffChecker.swift
//  SushiBelt
//
//  Created by david on 2022/03/09.
//

import Foundation

public protocol SushiBeltTrackerItemDiffChecker {
  
  func diff(old oldItems: Set<SushiBeltTrackerItem>, new newItems: Set<SushiBeltTrackerItem>) -> SushiBeltTrackerItemDiffResult
}

public final class DefaultSushiBeltTrackerItemDiffChecker: SushiBeltTrackerItemDiffChecker {
  
  public func diff(
    old oldItems: Set<SushiBeltTrackerItem>,
    new newItems: Set<SushiBeltTrackerItem>
  ) -> SushiBeltTrackerItemDiffResult {
    let updatedItems: Set<SushiBeltTrackerItem> = self.union(
      oldItems: oldItems,
      newItems: newItems
    )
    
    let endedItems = updatedItems.subtracting(newItems)
    let newItems = updatedItems.subtracting(oldItems)
    
    return SushiBeltTrackerItemDiffResult(
      calculationTargetedItems: updatedItems.subtracting(endedItems),
      newItems: newItems,
      endedItems: endedItems
    )
  }
  
  private func union(
    oldItems: Set<SushiBeltTrackerItem>,
    newItems: Set<SushiBeltTrackerItem>
  ) -> Set<SushiBeltTrackerItem> {
    var updatedItems = [Int: SushiBeltTrackerItem]()
    oldItems.forEach { updatedItems[$0.hashValue] = $0 }

    for newItem in newItems {
      if let existingItem = updatedItems[newItem.hashValue] {
        var updatedItem = existingItem
        updatedItem.rect = newItem.rect
        updatedItems[newItem.hashValue] = updatedItem
      } else {
        updatedItems[newItem.hashValue] = newItem
      }
    }

    return Set(updatedItems.values)
  }
}
