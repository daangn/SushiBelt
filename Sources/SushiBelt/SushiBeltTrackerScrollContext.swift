//
//  SushiBeltTrackerScrollContext.swift
//  SushiBelt
//
//  Created by Jaxtyn on 2022/08/16.
//

import Foundation

#if !os(macOS)

import UIKit

public typealias PlatformScrollView = UIScrollView

#else

import AppKit

public typealias PlatformScrollView = NSScrollView

#endif

public protocol SushiBeltTrackerScrollContext: AnyObject {
  func scrollDrection() -> SushiBeltTrackerScrollDirection?
}

public final class SushiBeltTrackerUIScrollContext: SushiBeltTrackerScrollContext {
  weak var scrollView: PlatformScrollView?

  public init(scrollView: PlatformScrollView) {
    self.scrollView = scrollView
  }

  public func scrollDrection() -> SushiBeltTrackerScrollDirection? {
    guard let scrollView = self.scrollView else {
      return nil
    }

    let velocity = scrollView.panGestureRecognizer.velocity(in: nil)

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
      return .diagonal
    }
  }
}
