//
//  SushiBeltTrackerItemDiffCheckerTests.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import XCTest

@testable import SushiBelt

final class SushiBeltTrackerItemDiffCheckerTests: XCTestCase {
  
  private func createDefaultChecker() -> DefaultSushiBeltTrackerItemDiffChecker {
    return DefaultSushiBeltTrackerItemDiffChecker()
  }
}

// MARK: - update frame in window

extension SushiBeltTrackerItemDiffCheckerTests {
  
  func test_diff_overlaped_items_should_update_recent_frame_in_window() {
    // given
    let checker = self.createDefaultChecker()
    
    let oldItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ).frameInWindow(
        CGRect(
          origin: CGPoint(x: 0.0, y: 0.0),
          size: CGSize(width: 100, height: 100)
        )
      ).tracked()
    ])
    
    let newItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ).frameInWindow(
        CGRect(
          origin: CGPoint(x: 0.0, y: 100.0),
          size: CGSize(width: 100, height: 100)
        )
      )
    ])
    
    // when
    let result = checker.diff(old: oldItems, new: newItems)
    let resultItem = result.calculationTargetedItems.first
    let frameInWindow = resultItem?.rect.frameInWindow
    
    // then
    XCTAssertEqual(result.calculationTargetedItems.count, 1)
    XCTAssertEqual(resultItem?.isTracked, true)
    XCTAssertEqual(frameInWindow?.origin.x, 0.0)
    XCTAssertEqual(frameInWindow?.origin.y, 100.0)
    XCTAssertEqual(frameInWindow?.size.width, 100.0)
    XCTAssertEqual(frameInWindow?.size.height, 100.0)
  }
}

// MARK: - diff calculationTargeted & new/ended items

extension SushiBeltTrackerItemDiffCheckerTests {
  
  func test_initial_diff_should_return_calculationTargetedItems_only() {
    // given
    let tracker = self.createDefaultChecker()
    let oldItems = Set<SushiBeltTrackerItem>([])
    let newItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      )
    ])
    
    // when
    let result = tracker.diff(old: oldItems, new: newItems)
    
    // then
    XCTAssertEqual(result.calculationTargetedItems.count, 1)

    XCTAssertEqual(result.newItems.count, 1)
    XCTAssertEqual(result.newItems.first?.id, .index(1))

    XCTAssertEqual(result.endedItems.count, 0)
  }
  
  func test_diff_new_items_come_in_case_old_items_should_return_as_endedItems() {
    // given
    let tracker = self.createDefaultChecker()
    let oldItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      )
    ])
    
    let newItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(200),
        rect: .init(frame: .zero)
      )
    ])
    
    // when
    let result = tracker.diff(old: oldItems, new: newItems)
    
    // then
    XCTAssertEqual(result.calculationTargetedItems.count, 1)
    XCTAssertEqual(result.calculationTargetedItems.first, newItems.first)

    XCTAssertEqual(result.newItems.count, 1)
    XCTAssertEqual(result.newItems.first?.id, .index(200))

    XCTAssertEqual(result.endedItems.count, 1)
    XCTAssertEqual(result.endedItems.first?.id, .index(1))
  }
  
  func test_diff_overlaped_items_should_return_as_calculationTargetedItems() {
    // given
    let tracker = self.createDefaultChecker()
    let oldItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      )
    ])
    
    let newItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ),
      SushiBeltTrackerItem(
        id: .index(200),
        rect: .init(frame: .zero)
      )
    ])
    
    // when
    let result = tracker.diff(old: oldItems, new: newItems)
    
    // then
    XCTAssertEqual(result.calculationTargetedItems.count, 2)
    XCTAssertTrue(result.calculationTargetedItems.contains(where: { item in
      guard case let .index(index) = item.id else { return false }
      return index == 1
    }))

    XCTAssertEqual(result.newItems.count, 1)
    XCTAssertEqual(result.newItems.first?.id, .index(200))

    XCTAssertEqual(result.endedItems.count, 0)
  }
  
  func test_diff_non_overlaped_items_should_return_as_endedItems() {
    // given
    let tracker = self.createDefaultChecker()
    let oldItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ),
      SushiBeltTrackerItem(
        id: .index(100),
        rect: .init(frame: .zero)
      )
    ])
    
    let newItems = Set<SushiBeltTrackerItem>([
      SushiBeltTrackerItem(
        id: .index(100),
        rect: .init(frame: .zero)
      ),
      SushiBeltTrackerItem(
        id: .index(200),
        rect: .init(frame: .zero)
      )
    ])
    
    // when
    let result = tracker.diff(old: oldItems, new: newItems)
    
    // then
    XCTAssertEqual(result.calculationTargetedItems.count, 2)
    XCTAssertEqual(result.calculationTargetedItems, newItems)

    XCTAssertEqual(result.newItems.count, 1)
    XCTAssertEqual(result.newItems.first?.id, .index(200))

    XCTAssertEqual(result.endedItems.count, 1)
    XCTAssertEqual(result.endedItems.first?.id, .index(1))
  }

  func test_diff_overlapped_items_performance_test() {
    measure {
      // given
      let tracker = self.createDefaultChecker()

      let oldItems = Set<SushiBeltTrackerItem>(
        (0..<10000).map {
          SushiBeltTrackerItem(
            id: .index($0),
            rect: .init(frame: .zero)
          )
        }
      )
      
      let newItems = Set<SushiBeltTrackerItem>(
        (0..<10000).map {
          SushiBeltTrackerItem(
            id: .index($0),
            rect: .init(frame: .zero)
          )
        }
      )

      // when
      _ = tracker.diff(old: oldItems, new: newItems)
    }
  }
}
