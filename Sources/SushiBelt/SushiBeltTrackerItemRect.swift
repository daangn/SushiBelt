//
//  SushiBeltTrackerItemRect.swift
//  SushiBelt
//
//  Created by Jaxtyn on 2022/08/16.
//

import Foundation

#if !os(macOS)

import UIKit

typealias PlatformView = UIView

#else

import AppKit

typealias PlatformView = NSView

#endif

struct SushiBeltTrackerItemRect {
  let frameInWindow: CGRect

  init(frame: CGRect) {
    self.frameInWindow = frame
  }

  init(origin: CGPoint, size: CGSize) {
    self.frameInWindow = .init(origin: origin, size: size)
  }

  init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
    self.frameInWindow = .init(x: x, y: y, width: width, height: height)
  }

  init(x: Double, y: Double, width: Double, height: Double) {
    self.frameInWindow = .init(x: x, y: y, width: width, height: height)
  }

  init(x: Int, y: Int, width: Int, height: Int) {
    self.frameInWindow = .init(x: x, y: y, width: width, height: height)
  }
}

extension PlatformView {
  func sushiBeltTrackerItemRect() -> SushiBeltTrackerItemRect {
    return .init(frame: self.convert(self.bounds, to: nil))
  }
}
