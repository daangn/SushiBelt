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
  
  private var visibleRatioCalculator: VisibleRatioCalculator = DefaultVisibleRatioCalculator()
  
  public var defaultVisibleRatio: CGFloat = 0.0
  public var defaultScrollDirection: SushiBeltTrackerScrollDirection = .up
  internal var recentScrollDirection: SushiBeltTrackerScrollDirection?
  
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
    self.recentScrollDirection = scrollDirection
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
      scrollDirection: self.recentScrollDirection
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
    guard let trackingRect = self.dataSource?.trackingRect(self) else {
      return
    }
            
    items.forEach { item in
      // early exit
      if !item.isTracked && self.debugger == nil {
        return
      }
      
      guard let currentVisibleRatio = self.visibleRatioCalculator.visibleRatio(
        item: item,
        trackingRect: trackingRect,
        scrollDirection: self.scrollDrection()
      ) else {
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
  
  internal func scrollDrection() -> SushiBeltTrackerScrollDirection? {
    guard let velocity = self.scrollView?.panGestureRecognizer.velocity(in: nil)
    else {
      assertionFailure("scrollView must not be null")
      return nil
    }
    
    if velocity.x == 0.0 && velocity.y == 0.0 {
      return self.recentScrollDirection ?? self.defaultScrollDirection
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
  
}
