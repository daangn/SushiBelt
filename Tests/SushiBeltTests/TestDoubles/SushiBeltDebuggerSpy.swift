//
//  SushiBeltDebuggerSpy.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

@testable import SushiBelt

final class SushiBeltDebuggerSpy: SushiBeltDebuggerLogic {
  
  var showCalled: Int = 0
  
  func show() {
    self.showCalled += 1
  }
  
  var hideCalled: Int = 0
  
  func hide() {
    self.hideCalled += 1
  }
  
  var configureCalled: Int = 0
  
  func configure(_ configuration: SushiBeltDebuggerConfiguration) {
    self.configureCalled += 1
  }
  
  var updateItems: Set<SushiBeltTrackerItem>?
  var updateScrollDirection: SushiBeltTrackerScrollDirection?
  
  func update(
    items: Set<SushiBeltTrackerItem>,
    scrollDirection: SushiBeltTrackerScrollDirection?
  ) {
    self.updateItems = items
    self.updateScrollDirection = scrollDirection
  }
}
