//
//  SushiBeltTracker.swift
//  SushiBeltTracker
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public final class SushiBeltTracker {
  
  // MARK: - Dependencies
  public weak var delegate: SushiBeltTrackerDelegate?
  public weak var dataSource: SushiBeltTrackerDataSource?
  public var scrollContext: SushiBeltTrackerScrollContext?
  private let visibleRatioCalculator: VisibleRatioCalculator
  private let trackerItemDiffChecker: SushiBeltTrackerItemDiffChecker
  private var debugger: SushiBeltDebuggerLogic?
  
  // MARK: - State
  public var defaultVisibleRatio: CGFloat = 0.0
  public var defaultScrollDirection: SushiBeltTrackerScrollDirection = .up
  internal var recentScrollDirection: SushiBeltTrackerScrollDirection?
  internal var cachedItems: Set<SushiBeltTrackerItem> = .init()
  
  // MARK: - Constructor
  
  public convenience init() {
    self.init(
      visibleRatioCalculator: nil,
      trackerItemDiffChecker: nil
    )
  }
  
  public init(
    visibleRatioCalculator: VisibleRatioCalculator? = nil,
    trackerItemDiffChecker: SushiBeltTrackerItemDiffChecker? = nil
  ) {
    self.visibleRatioCalculator = visibleRatioCalculator ?? DefaultVisibleRatioCalculator()
    self.trackerItemDiffChecker = trackerItemDiffChecker ?? DefaultSushiBeltTrackerItemDiffChecker()
  }
  
  public func calculateItemsIfNeeded(items: [SushiBeltTrackerItem]) {
    let result = self.trackerItemDiffChecker.diff(
      old: self.cachedItems,
      new: Set<SushiBeltTrackerItem>(items)
    )
    
    self.cachedItems = result.calculationTargetedItems
    self.willBeginTracking(items: result.newItems)
    self.checkBeginTrackingItems(items: self.cachedItems)
    self.didEndTracking(items: result.endedItems)
    
    self.debuggingIfNeeded()
    self.cachingRecentScrollDirectionIfNeeded()
  }
  
  public func registerDebugger(debugger: SushiBeltDebuggerLogic) {
    self.debugger = debugger
  }
  
}

// MARK: - SushiBeltTracker Internal Extension

extension SushiBeltTracker {
  
  internal func checkBeginTrackingItems(items: Set<SushiBeltTrackerItem>) {
    guard let trackingRect = self.dataSource?.trackingRect(self) else {
      return
    }
            
    items.forEach { item in
      // early exit
      if item.isTracked && self.debugger == nil {
        return
      }
      
      guard let currentVisibleRatio = self.visibleRatioCalculator.visibleRatio(
        item: item,
        trackingRect: trackingRect,
        scrollDirection: self.scrollDrection()
      ) else {
        return
      }
      
      let objectiveVisibleRatio = self.objectiveVisibleRatio(item: item)
      
      let isTracked: Bool = currentVisibleRatio >= objectiveVisibleRatio
      let shouldSendWillBeginTracking: Bool = !item.isTracked && isTracked
      
      var mutableItem = item
      mutableItem.currentVisibleRatio = currentVisibleRatio
      mutableItem.objectiveVisibleRatio = objectiveVisibleRatio
      
      /// delegate willBeginTracking
      if shouldSendWillBeginTracking {
        mutableItem.isTracked = true
        self.delegate?.didTrack(self, item: mutableItem)
      }
      
      /// update cached item
      guard shouldSendWillBeginTracking || self.debugger != nil else { return }
      self.cachedItems.update(with: mutableItem)
    }
  }
  
  internal func scrollDrection() -> SushiBeltTrackerScrollDirection? {
    guard let scrollContext = self.scrollContext else {
      assertionFailure("scrollContext must not be null")
      return nil
    }

    if let scrollDrection = scrollContext.scrollDrection() {
      // unsupported diagonal scroll tracking
      return scrollDrection == .diagonal ? nil : scrollDrection
    } else {
      return self.recentScrollDirection ?? self.defaultScrollDirection
    }
  }
}

// MARK: - SushiBeltTracker Private Extension

extension SushiBeltTracker {
  
  private func cachingRecentScrollDirectionIfNeeded() {
    guard let scrollDirection = self.scrollDrection() else { return }
    self.recentScrollDirection = scrollDirection
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

  private func willBeginTracking(items: Set<SushiBeltTrackerItem>) {
    items.forEach {
      self.delegate?.willBeginTracking(self, item: $0)
    }
  }

  private func didEndTracking(items: Set<SushiBeltTrackerItem>) {
    items.forEach {
      self.delegate?.didEndTracking(self, item: $0)
    }
  }
  
  private func objectiveVisibleRatio(item: SushiBeltTrackerItem) -> CGFloat {
    return self.dataSource?.visibleRatioForItem(self, item: item)
    ?? self.defaultVisibleRatio
  }
}
