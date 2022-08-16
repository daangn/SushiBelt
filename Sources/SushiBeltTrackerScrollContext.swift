//
//  SushiBeltTrackerScrollContext.swift
//  SushiBelt
//
//  Created by Jaxtyn on 2022/08/16.
//

import Foundation

#if !os(macOS)

import UIKit

typealias PlatformScrollView = UIScrollView

#else

import AppKit

typealias PlatformScrollView = NSScrollView

#endif

public protocol SushiBeltTrackerScrollContext: AnyObject {
  func scrollDrection() -> SushiBeltTrackerScrollDirection?
}

extension PlatformScrollView: SushiBeltTrackerScrollContext {
  public func scrollDrection() -> SushiBeltTrackerScrollDirection? {
    let velocity = self.panGestureRecognizer.velocity(in: nil)

    if velocity.x == 0.0 && velocity.y == 0.0 {
      return nil
    } else if velocity.x == 0.0 && velocity.y < 0.0 {
      return .up
    } else if velocity.x == 0.0 && velocity.y > 0.0 {
      return .down
    } else if velocity.x < 0.0 && velocity.y == 0.0 {
      return .right
    } else if velocity.x > 0.0 && velocity.y == 0.0 {
      return .left
    } else {
      return nil
    }
  }
}
