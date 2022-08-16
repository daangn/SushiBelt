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

public struct SushiBeltTrackerItemRect {
  let frameInWindow: CGRect
}

public extension PlatformView {
  func sushiBeltTrackerItemRect() -> SushiBeltTrackerItemRect {
    return .init(frameInWindow: self.convert(self.bounds, to: nil))
  }
}
