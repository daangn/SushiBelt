//
//  SushiBeltTracker.swift
//  SushiBeltTracker
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public final class SushiBeltTracker {
  
  public weak var delegate:  SushiBeltTrackerDelegate?
  public weak var dataSource: SushiBeltTrackerDataSource?
  public weak var scrollView: UIScrollView?
  
  public var defaultVisibleRatio: CGFloat = 0.0
  public var defaultScrollDirection: SushiBeltTrackerScrollDirection = .up
  private var prevScrollDirection: SushiBeltTrackerScrollDirection?
  
  private var cachedItems: Set<SushiBeltTrackerItem> = .init()
  private var debugger: SushiBeltDebuggerLogic?
  
  public init() {
    
  }
  
  public convenience init(scrollView: UIScrollView) {
    self.init()
    self.scrollView = scrollView
  }
  
  public convenience init(
    scrollView: UIScrollView,
    dataSource: SushiBeltTrackerDataSource,
    delegate:  SushiBeltTrackerDelegate
  ) {
    self.init()
    self.scrollView = scrollView
    self.dataSource = dataSource
    self.delegate = delegate
  }
  
  public func calculateItemsIfNeeded(items: [SushiBeltTrackerItem]) {
    self.updateCachedItemsIfNeeded(items: items)
    let endTrackingItems = self.cachedItems.subtracting(items)
    self.removeEndTrackingItemsOnCache(items: endTrackingItems)
    self.checkBeginTrackingItems(items: self.cachedItems)
    self.didEndTracking(items: endTrackingItems)
    self.debuggingIfNeeded()
    guard let scrollDirection = self.scrollDrection() else { return }
    self.prevScrollDirection = scrollDirection
  }
  
  public func registerDebugger(debugger: SushiBeltDebuggerLogic) {
    self.debugger = debugger
  }
  
  private func removeEndTrackingItemsOnCache(items: Set<SushiBeltTrackerItem>) {
    items.forEach { item in
      self.cachedItems.remove(item)
    }
  }
  
  private func debuggingIfNeeded() {
    guard let debugger = self.debugger else {
      return
    }
    debugger.update(
      items: self.cachedItems,
      scrollDirection: self.prevScrollDirection
    )
  }
  
  private func updateCachedItemsIfNeeded(items: [SushiBeltTrackerItem]) {
    items.forEach { item in
      if var cachedItem = self.cachedItems.first(where: { $0.hashValue == item.hashValue }) {
        cachedItem.frameInWindow = item.frameInWindow
        self.cachedItems.update(with: cachedItem)
      } else {
        self.cachedItems.insert(item)
      }
    }
  }
  
  private func checkBeginTrackingItems(items: Set<SushiBeltTrackerItem>) {
    items.forEach { item in
      // early exit
      if !item.isTracked && self.debugger == nil {
        return
      }
      
      guard let currentVisibleRatio = self.calculateVisibleRatio(item: item) else {
        return
      }
      
      let objectiveVisibleRatio = self.dataSource?.visibleRatioForItem(self, item: item) ?? self.defaultVisibleRatio
      
      var mutableItem = item
      var shouldUpdate: Bool = false
      
      if !mutableItem.isTracked && currentVisibleRatio >= objectiveVisibleRatio {
        mutableItem.isTracked = true
        shouldUpdate = true
        self.delegate?.willBeginTracking(self, item: item)
      }
      
      if self.debugger != nil {
        mutableItem.currentVisibleRatio = currentVisibleRatio
        mutableItem.objectiveVisibleRatio = objectiveVisibleRatio
        shouldUpdate = true
      }
      
      guard shouldUpdate else { return }
      self.cachedItems.update(with: mutableItem)
    }
  }
  
  private func didEndTracking(items: Set<SushiBeltTrackerItem>) {
    items.forEach {
      self.delegate?.didEndTracking(self, item: $0)
    }
  }
  
  private func calculatedTrackingRect(item: SushiBeltTrackerItem,
                                      objectiveVisibleRatio: CGFloat) -> CGRect {
    guard let trackingRect = self.dataSource?.trackingRect(self) else {
      assertionFailure("You must inherit SushiBeltTrackerDataSource")
      return .zero
    }
    
    guard let scrollDirection = self.scrollDrection() else {
      return .zero
    }
    
    switch scrollDirection {
    case .up:
      let height = item.frameInWindow.height * objectiveVisibleRatio
      return CGRect(
        x: trackingRect.origin.x,
        y: trackingRect.origin.y,
        width: trackingRect.width,
        height: trackingRect.height - height
      )
    case .down:
      let height = item.frameInWindow.height * objectiveVisibleRatio
      return CGRect(
        x: trackingRect.origin.x,
        y: trackingRect.origin.y + height,
        width: trackingRect.width,
        height: trackingRect.height - height
      )
    case .left:
      let width = item.frameInWindow.width * objectiveVisibleRatio
      return CGRect(
        x: trackingRect.origin.x,
        y: trackingRect.origin.y,
        width: trackingRect.width - width,
        height: trackingRect.height
      )
    case .right:
      let width = item.frameInWindow.width * objectiveVisibleRatio
      return CGRect(
        x: trackingRect.origin.x + width,
        y: trackingRect.origin.y,
        width: trackingRect.width - width,
        height: trackingRect.height
      )
    }
  }
  
  private func scrollDrection() -> SushiBeltTrackerScrollDirection? {
    guard let velocity = self.scrollView?.panGestureRecognizer.velocity(in: nil)
    else {
      assertionFailure("scrollView must not be null")
      return nil
    }
    
    if velocity.x == 0.0 && velocity.y == 0.0 {
      return self.prevScrollDirection ?? self.defaultScrollDirection
    } else if velocity.x == 0.0 && velocity.y < 0.0 {
      return .up
    } else if velocity.x == 0.0 && velocity.y > 0.0 {
      return .down
    } else if velocity.x < 0.0 && velocity.y == 0.0 {
      return .right
    } else if velocity.x > 0.0 && velocity.y == 0.0 {
      return .left
    }
    
    // unsupported diagonal scroll tracking
    return nil
  }
  
  private func calculateVisibleRatio(
    item: SushiBeltTrackerItem
  ) -> CGFloat? {
    guard let trackingRect = self.dataSource?.trackingRect(self)
    else {
      return nil
    }
    
    let visibleRect = trackingRect.intersection(item.frameInWindow)
    
    switch self.scrollDrection() {
    case .up, .down:
      return min(1.0, visibleRect.height / item.frameInWindow.height)
    case .left, .right:
      return min(1.0, visibleRect.width / item.frameInWindow.width)
    default:
      return nil
    }
  }
}
