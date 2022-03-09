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
    
    fatalError()
  }
  
}
