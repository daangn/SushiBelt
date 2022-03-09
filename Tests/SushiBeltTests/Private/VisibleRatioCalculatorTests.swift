//
//  VisibleRatioCalculatorTests.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit
import XCTest

@testable import SushiBelt

final class VisibleRatioCalculatorTests: XCTestCase {
  
  private func defaultVisibleRatioCalculator() -> DefaultVisibleRatioCalculator {
    return DefaultVisibleRatioCalculator()
  }
}

// MARK:- default visibleRatioCalculator visible ratio

extension VisibleRatioCalculatorTests {
  
  func test_early_exit_in_scrollDirection_null() {
    // given
    let calculator = self.defaultVisibleRatioCalculator()
    
    // when
    let ratio = calculator.visibleRatio(
      item: SushiBeltTrackerItem(id: .index(1), view: UIView(frame: .zero)),
      trackingRect: CGRect(origin: .zero, size: .zero),
      scrollDirection: nil
    )
    
    // then
    XCTAssertNil(ratio)
  }
  
  func test_should_return_expected_visible_ratio_on_scroll_up() {
    // given
    let calculator = self.defaultVisibleRatioCalculator()
    
    let givenFrameInWindows: [CGRect] = [
      CGRect(origin: .init(x: 0.0, y: 1000.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 0.0, y: 750.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 0.0, y: 500.0), size: CGSize(width: 500, height: 500))
    ]
    
    let expectedVisibleRatio: [CGFloat] = [0.0, 0.5, 1.0]
    
    givenFrameInWindows.enumerated().forEach { index, frameInWindow in
      // when
      var item = SushiBeltTrackerItem(id: .index(1), view: UIView(frame: .zero))
      item.frameInWindow = frameInWindow
      
      let ratio = calculator.visibleRatio(
        item: item,
        trackingRect: CGRect(origin: .zero, size: CGSize(width: 500, height: 1000)),
        scrollDirection: .up
      )
      
      // then
      XCTAssertEqual(ratio, expectedVisibleRatio[index])
    }
  }
  
  func test_should_return_expected_visible_ratio_on_scroll_down() {
    // given
    let calculator = self.defaultVisibleRatioCalculator()
    
    let givenFrameInWindows: [CGRect] = [
      CGRect(origin: .init(x: 0.0, y: -500.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 0.0, y: -250.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 0.0, y: 0.0), size: CGSize(width: 500, height: 500))
    ]
    
    let expectedVisibleRatio: [CGFloat] = [0.0, 0.5, 1.0]
    
    givenFrameInWindows.enumerated().forEach { index, frameInWindow in
      // when
      var item = SushiBeltTrackerItem(id: .index(1), view: UIView(frame: .zero))
      item.frameInWindow = frameInWindow
      
      let ratio = calculator.visibleRatio(
        item: item,
        trackingRect: CGRect(origin: .zero, size: CGSize(width: 500, height: 1000)),
        scrollDirection: .down
      )
      
      // then
      XCTAssertEqual(ratio, expectedVisibleRatio[index])
    }
  }
  
  func test_should_return_expected_visible_ratio_on_scroll_left() {
    // given
    let calculator = self.defaultVisibleRatioCalculator()
    
    let givenFrameInWindows: [CGRect] = [
      CGRect(origin: .init(x: 1000.0, y: 0.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 750.0, y: 0.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 500.0, y: 0.0), size: CGSize(width: 500, height: 500))
    ]
    
    let expectedVisibleRatio: [CGFloat] = [0.0, 0.5, 1.0]
    
    givenFrameInWindows.enumerated().forEach { index, frameInWindow in
      // when
      var item = SushiBeltTrackerItem(id: .index(1), view: UIView(frame: .zero))
      item.frameInWindow = frameInWindow
      
      let ratio = calculator.visibleRatio(
        item: item,
        trackingRect: CGRect(origin: .zero, size: CGSize(width: 1000, height: 500)),
        scrollDirection: .left
      )
      
      // then
      XCTAssertEqual(ratio, expectedVisibleRatio[index])
    }
  }
  
  func test_should_return_expected_visible_ratio_on_scroll_right() {
    // given
    let calculator = self.defaultVisibleRatioCalculator()
    
    let givenFrameInWindows: [CGRect] = [
      CGRect(origin: .init(x: -500.0, y: 0.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: -250.0, y: 0.0), size: CGSize(width: 500, height: 500)),
      CGRect(origin: .init(x: 0.0, y: 0.0), size: CGSize(width: 500, height: 500))
    ]
    
    let expectedVisibleRatio: [CGFloat] = [0.0, 0.5, 1.0]
    
    givenFrameInWindows.enumerated().forEach { index, frameInWindow in
      // when
      var item = SushiBeltTrackerItem(id: .index(1), view: UIView(frame: .zero))
      item.frameInWindow = frameInWindow
      
      let ratio = calculator.visibleRatio(
        item: item,
        trackingRect: CGRect(origin: .zero, size: CGSize(width: 1000, height: 500)),
        scrollDirection: .right
      )
      
      // then
      XCTAssertEqual(ratio, expectedVisibleRatio[index])
    }
  }
  
  
}
