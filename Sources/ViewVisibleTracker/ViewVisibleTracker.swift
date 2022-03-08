//
//  ViewVisibleTracker.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public final class ViewVisibleTracker {
  
  public weak var delegate: ViewVisibleTrackerDelegate?
  public weak var dataSource: ViewVisibleTrackerDataSource?
  public weak var scrollView: UIScrollView?
  
  public var defaultVisibleRatio: CGFloat = 0.0
  public var defaultScrollDirection: ViewVisibleTrackerScrollDirection = .up
  
  private var cachedItems: Set<ViewVisibleTrackingItem> = .init()
  private var debugger: ViewVisibleTrackerDebuggerLogic?
  
  public init() {
    
  }
  
  public convenience init(scrollView: UIScrollView) {
    self.init()
    self.scrollView = scrollView
  }
  
  public convenience init(
    scrollView: UIScrollView,
    dataSource: ViewVisibleTrackerDataSource,
    delegate: ViewVisibleTrackerDelegate
  ) {
    self.init()
    self.scrollView = scrollView
    self.dataSource = dataSource
    self.delegate = delegate
  }
  
  public func calculateItemsIfNeeded(items: [ViewVisibleTrackingItem]) {
    self.updateCachedItemsIfNeeded(items: items)
    let endTrackingItems = self.cachedItems.subtracting(items)
    self.removeEndTrackingItemsOnCache(items: endTrackingItems)
    self.checkBeginTrackingItems(items: self.cachedItems)
    self.didEndTracking(items: endTrackingItems)
  
  public func registerDebugger(debugger: ViewVisibleTrackerDebuggerLogic) {
    self.debugger = debugger
  }
  
  private func removeEndTrackingItemsOnCache(items: Set<ViewVisibleTrackingItem>) {
    items.forEach { item in
      self.cachedItems.remove(item)
    }
  }
  
  private func updateCachedItemsIfNeeded(items: [ViewVisibleTrackingItem]) {
    items.forEach { item in
      if var cachedItem = self.cachedItems.first(where: { $0.hashValue == item.hashValue }) {
        cachedItem.frameInWindow = item.frameInWindow
        self.cachedItems.update(with: cachedItem)
      } else {
        self.cachedItems.insert(item)
      }
    }
  }
  
  private func checkBeginTrackingItems(items: Set<ViewVisibleTrackingItem>) {
    items.forEach { item in
      guard !item.isTracked,
            let trackingItemPoint = self.trackingItemPoint(item: item),
            self.calculatedTrackingRect(item: item).contains(trackingItemPoint)
      else {
        return
      }
      
      var mutableItem = item
      mutableItem.isTracked = true
      self.cachedItems.update(with: mutableItem)
      self.delegate?.willBeginTracking(self, item: item)
    }
  }
  
  private func didEndTracking(items: Set<ViewVisibleTrackingItem>) {
    items.forEach {
      self.delegate?.didEndTracking(self, item: $0)
    }
  }
  
  private func trackingItemPoint(item: ViewVisibleTrackingItem) -> CGPoint? {
    guard let direction = self.scrollDrection() else { return nil }
    switch direction {
    case .up:
      return CGPoint(
        x: item.frameInWindow.origin.x,
        y: item.frameInWindow.origin.y
      )
    case .down:
      return CGPoint(
        x: item.frameInWindow.origin.x,
        y: item.frameInWindow.origin.y + item.frameInWindow.height
      )
    case .left:
      return CGPoint(
        x: item.frameInWindow.origin.x,
        y: item.frameInWindow.origin.y
      )
    case .right:
      return CGPoint(
        x: item.frameInWindow.origin.x + item.frameInWindow.width,
        y: item.frameInWindow.origin.y
      )
    }
  }
  
  private func calculatedTrackingRect(item: ViewVisibleTrackingItem) -> CGRect {
    guard let trackingRect = self.dataSource?.trackingRect(self) else {
      assertionFailure("You must inherit ViewVisibleTrackerDataSource")
      return .zero
    }
    
    guard let scrollDirection = self.scrollDrection() else {
      return .zero
    }
    
    let ratio = self.dataSource?.visibleRatioForItem(self, item: item) ?? self.defaultVisibleRatio
    
    switch scrollDirection {
    case .up:
      let height = item.frameInWindow.height * ratio
      return CGRect(
        x: trackingRect.origin.x,
        y: trackingRect.origin.y,
        width: trackingRect.width,
        height: trackingRect.height - height
      )
    case .down:
      let height = item.frameInWindow.height * ratio
      return CGRect(
        x: trackingRect.origin.x,
        y: trackingRect.origin.y + height,
        width: trackingRect.width,
        height: trackingRect.height - height
      )
    case .left:
      let width = item.frameInWindow.width * ratio
      return CGRect(
        x: trackingRect.origin.x,
        y: trackingRect.origin.y,
        width: trackingRect.width - width,
        height: trackingRect.height
      )
    case .right:
      let width = item.frameInWindow.width * ratio
      return CGRect(
        x: trackingRect.origin.x + width,
        y: trackingRect.origin.y,
        width: trackingRect.width - width,
        height: trackingRect.height
      )
    }
  }
  
  private func scrollDrection() -> ViewVisibleTrackerScrollDirection? {
    guard let velocity = self.scrollView?.panGestureRecognizer.velocity(in: nil) else {
      assertionFailure("scrollView must not be null")
      return nil
    }
    
    if velocity.x == 0.0 && velocity.y == 0.0 {
      return self.defaultScrollDirection
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
