//
//  VisibleStateDetectorSpy.swift
//  SushiBeltTests
//
//  Created by 1Consumption on 2026/09/18.
//

import UIKit
@testable import KarrotImpression

final class VisibleStateDetectorSpy: VisibleStateDetectable {

  weak var delegate: VisibleStateDetectorDelegate?

  private(set) var detectCallCount = 0
  private(set) var clearCallCount = 0
  private(set) var showDebuggerCallCount = 0

  var onDetect: (() -> Void)?
  var onClear: (() -> Void)?

  func detect(items: [VisibleStateDetectorItem], trackingRect: @escaping () -> CGRect) {
    self.detectCallCount += 1
    self.onDetect?()
  }

  func clear() {
    self.clearCallCount += 1
    self.onClear?()
  }

  func showDebugger() {
    self.showDebuggerCallCount += 1
  }
}
