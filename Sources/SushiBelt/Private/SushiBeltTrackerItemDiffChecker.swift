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
    
    return SushiBeltTrackerItemDiffResult(
      calculationTargetedItems: updatedItems.subtracting(endedItems),
      endedItems: endedItems
    )
  }
  
  private func union(
    oldItems: Set<SushiBeltTrackerItem>,
    newItems: Set<SushiBeltTrackerItem>
  ) -> Set<SushiBeltTrackerItem> {
    var updatedItems: Set<SushiBeltTrackerItem> = oldItems
    
    newItems.forEach { newItem in
      if var mutableItem = oldItems.first(where: { $0.hashValue == newItem.hashValue }) {
        mutableItem.rect = newItem.rect
        updatedItems.update(with: mutableItem)
      } else {
        updatedItems.insert(newItem)
      }
    }
    
    return updatedItems
  }
  
}
