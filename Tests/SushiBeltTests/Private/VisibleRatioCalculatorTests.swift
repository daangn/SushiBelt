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
  
  func test_should_return_expected_visible_ratio() {
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
      var item = SushiBeltTrackerItem(id: .index(1), rect: .init(frame: .zero))
      item.rect = .init(frame: frameInWindow)
      
      let ratio = calculator.visibleRatio(
        item: item,
        trackingRect: CGRect(origin: .zero, size: CGSize(width: 500, height: 1000))
      )
      
      // then
      XCTAssertEqual(ratio, expectedVisibleRatio[index])
    }
  }
  
  
  
  
  
}
