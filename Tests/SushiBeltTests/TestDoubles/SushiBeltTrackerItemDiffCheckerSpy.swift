//
//  SushiBeltTrackerItemDiffCheckerSpy.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation

@testable import SushiBelt

final class SushiBeltTrackerItemDiffCheckerSpy: SushiBeltTrackerItemDiffChecker {
  
  var diffOldItems: Set<SushiBeltTrackerItem>?
  var diffNewItems: Set<SushiBeltTrackerItem>?
  var diffStub: SushiBeltTrackerItemDiffResult = .init(
    calculationTargetedItems: .init(),
    endedItems: .init()
  )
  
  func diff(old oldItems: Set<SushiBeltTrackerItem>, new newItems: Set<SushiBeltTrackerItem>) -> SushiBeltTrackerItemDiffResult {
    self.diffOldItems = oldItems
    self.diffNewItems = newItems
    return self.diffStub
  }
  
}
