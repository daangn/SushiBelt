//
//  SushiBeltTrackerItemRect.swift
//  SushiBelt
//
//  Created by Jaxtyn on 2022/08/16.
//

import Foundation

#if !os(macOS)

import UIKit

public typealias PlatformView = UIView

#else

import AppKit

public typealias PlatformView = NSView

#endif

public struct SushiBeltTrackerItemRect {
  let frameInWindow: CGRect

  public init(frame: CGRect) {
    self.frameInWindow = frame
  }

  public init(origin: CGPoint, size: CGSize) {
    self.frameInWindow = .init(origin: origin, size: size)
  }

  public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
    self.frameInWindow = .init(x: x, y: y, width: width, height: height)
  }

  public init(x: Double, y: Double, width: Double, height: Double) {
    self.frameInWindow = .init(x: x, y: y, width: width, height: height)
  }

  public init(x: Int, y: Int, width: Int, height: Int) {
    self.frameInWindow = .init(x: x, y: y, width: width, height: height)
  }
}

public extension PlatformView {
  func sushiBeltTrackerItemRect() -> SushiBeltTrackerItemRect {
    return .init(frame: self.convert(self.bounds, to: nil))
  }
}
