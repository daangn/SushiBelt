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

  let trackingRectInWindow: CGRect?

  init(frame: CGRect, trackingRectInWindow: CGRect? = nil) {
    self.frameInWindow = frame
    self.trackingRectInWindow = trackingRectInWindow
  }

  func visibleRect(in viewport: CGRect) -> CGRect {
    let visibleRect = viewport.intersection(frameInWindow)
    guard let trackingRectInWindow else { return visibleRect }
    return visibleRect.intersection(trackingRectInWindow)
  }

  init(origin: CGPoint, size: CGSize) {
    self.init(frame: CGRect(origin: origin, size: size))
  }

  init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
    self.init(frame: CGRect(x: x, y: y, width: width, height: height))
  }

  init(x: Double, y: Double, width: Double, height: Double) {
    self.init(frame: CGRect(x: x, y: y, width: width, height: height))
  }

  init(x: Int, y: Int, width: Int, height: Int) {
    self.init(frame: CGRect(x: x, y: y, width: width, height: height))
  }
}

extension PlatformView {
  func sushiBeltTrackerItemRect() -> SushiBeltTrackerItemRect {
    return .init(frame: self.convert(self.bounds, to: nil))
  }
}
