//
//  SushiBeltTrackerItemTests.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import XCTest

@testable import SushiBelt

final class SushiBeltTrackerItemTests: XCTestCase {
  
  private func createItem(
    id: SushiBeltTrackerItem.Identifier,
    rect: SushiBeltTrackerItemRect
  ) -> SushiBeltTrackerItem {
    return SushiBeltTrackerItem(
      id: id,
      rect: rect
    )
  }
}

// MARK: - initialization

extension SushiBeltTrackerItemTests {
  
  func test_initialization_with_index() {
    let item = self.createItem(
      id: .index(100),
      rect: .init(
        frame: CGRect(
          origin: .zero,
          size: CGSize(
            width: 500.0,
            height: 500.0
          )
        )
      )
    )
    
    XCTAssertEqual(item.id, .index(100))
    
    XCTAssertEqual(item.status, .tracking)
    XCTAssertEqual(item.currentVisibleRatio, 0.0)
    XCTAssertEqual(item.objectiveVisibleRatio, 0.0)
    
    XCTAssertEqual(item.rect.frameInWindow.origin.x, 0.0)
    XCTAssertEqual(item.rect.frameInWindow.origin.y, 0.0)
    XCTAssertEqual(item.rect.frameInWindow.size.width, 500.0)
    XCTAssertEqual(item.rect.frameInWindow.size.height, 500.0)
  }
  
  func test_initialization_with_indexPath() {
    let item = self.createItem(
      id: .indexPath(IndexPath(item: 0, section: 2)),
      rect: .init(
        frame: CGRect(
          origin: .zero,
          size: CGSize(
            width: 500.0,
            height: 500.0
          )
        )
      )
    )
    
    XCTAssertEqual(item.id, .indexPath(IndexPath(item: 0, section: 2)))
    
    XCTAssertEqual(item.status, .tracking)
    XCTAssertEqual(item.currentVisibleRatio, 0.0)
    XCTAssertEqual(item.objectiveVisibleRatio, 0.0)
    
    XCTAssertEqual(item.rect.frameInWindow.origin.x, 0.0)
    XCTAssertEqual(item.rect.frameInWindow.origin.y, 0.0)
    XCTAssertEqual(item.rect.frameInWindow.size.width, 500.0)
    XCTAssertEqual(item.rect.frameInWindow.size.height, 500.0)
  }
  
  func test_initialization_with_custom() {
    let item = self.createItem(
      id: .trackingIdentifier(
        SushiBeltTrackerIdentifierStub(
          trackingIdentifer: "test"
        )
      ),
      rect: .init(
        frame: CGRect(
          origin: .zero,
          size: CGSize(
            width: 500.0,
            height: 500.0
          )
        )
      )
    )
    
    XCTAssertEqual(item.id, .trackingIdentifier(
      SushiBeltTrackerIdentifierStub(
        trackingIdentifer: "test"
      )
    ))
    
    XCTAssertEqual(item.status, .tracking)
    XCTAssertEqual(item.currentVisibleRatio, 0.0)
    XCTAssertEqual(item.objectiveVisibleRatio, 0.0)
    
    XCTAssertEqual(item.rect.frameInWindow.origin.x, 0.0)
    XCTAssertEqual(item.rect.frameInWindow.origin.y, 0.0)
    XCTAssertEqual(item.rect.frameInWindow.size.width, 500.0)
    XCTAssertEqual(item.rect.frameInWindow.size.height, 500.0)
  }
}

// MARK: - status

extension SushiBeltTrackerItemTests {
  
  func test_isTracked_false_should_be_tracking() {
    // given
    var item = self.createItem(
      id: .index(100),
      rect: .init(
        frame: CGRect(
          origin: .zero,
          size: CGSize(
            width: 500.0,
            height: 500.0
          )
        )
      )
    )
    
    // when
    item.isTracked = false
    
    // then
    XCTAssertEqual(item.status, .tracking)
  }
  
  func test_isTracked_true_should_be_tracked() {
    // given
    var item = self.createItem(
      id: .index(100),
      rect: .init(
        frame: CGRect(
          origin: .zero,
          size: CGSize(
            width: 500.0,
            height: 500.0
          )
        )
      )
    )
    
    // when
    item.isTracked = true
    
    // then
    XCTAssertEqual(item.status, .tracked)
  }
}

// MARK: - equatable

extension SushiBeltTrackerItemTests {
  
  // MARK: - equatable > index
  
  func test_equal_index() {
    // given
    let lhs = self.createItem(id: .index(1), rect: .init(frame: .zero))
    let rhs = self.createItem(id: .index(1), rect: .init(frame: .zero))
    
    // when
    let isEqual = lhs == rhs
    
    // then
    XCTAssertTrue(isEqual)
  }
  
  func test_not_equal_index() {
    // given
    let lhs = self.createItem(id: .index(1), rect: .init(frame: .zero))
    let rhs = self.createItem(id: .index(10), rect: .init(frame: .zero))
    
    // when
    let isEqual = lhs == rhs
    
    // then
    XCTAssertFalse(isEqual)
  }
  
  // MARK: - equatable > indexPath
  
  func test_equal_indexPath() {
    // given
    let lhs = self.createItem(
      id: .indexPath(IndexPath(item: 1, section: 1)),
      rect: .init(frame: .zero)
    )
    let rhs = self.createItem(
      id: .indexPath(IndexPath(item: 1, section: 1)),
      rect: .init(frame: .zero)
    )
    
    // when
    let isEqual = lhs == rhs
    
    // then
    XCTAssertTrue(isEqual)
  }
  
  func test_not_equal_indexPath() {
    // given
    let lhs = self.createItem(
      id: .indexPath(IndexPath(item: 1, section: 1)),
      rect: .init(frame: .zero)
    )
    let rhs = self.createItem(
      id: .indexPath(IndexPath(item: 1, section: 2)),
      rect: .init(frame: .zero)
    )
    
    // when
    let isEqual = lhs == rhs
    
    // then
    XCTAssertFalse(isEqual)
  }
  
  // MARK: - equatable > trackingIdentifier
  
  func test_equal_trackingIdentifier() {
    // given
    let lhs = self.createItem(
      id: .trackingIdentifier(SushiBeltTrackerIdentifierStub(trackingIdentifer: "1")),
      rect: .init(frame: .zero)
    )
    let rhs = self.createItem(
      id: .trackingIdentifier(SushiBeltTrackerIdentifierStub(trackingIdentifer: "1")),
      rect: .init(frame: .zero)
    )
    
    // when
    let isEqual = lhs == rhs
    
    // then
    XCTAssertTrue(isEqual)
  }
  
  func test_not_equal_trackingIdentifier() {
    // given
    let lhs = self.createItem(
      id: .trackingIdentifier(SushiBeltTrackerIdentifierStub(trackingIdentifer: "1")),
      rect: .init(frame: .zero)
    )
    let rhs = self.createItem(
      id: .trackingIdentifier(SushiBeltTrackerIdentifierStub(trackingIdentifer: "2")),
      rect: .init(frame: .zero)
    )
    
    // when
    let isEqual = lhs == rhs
    
    // then
    XCTAssertFalse(isEqual)
  }
}
