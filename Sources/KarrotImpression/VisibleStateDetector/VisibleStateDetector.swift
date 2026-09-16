//
//  VisibleStateDetector.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

final class VisibleStateDetector: VisibleStateDetectable {

  weak var delegate: VisibleStateDetectorDelegate?

  private let sushiBeltTracker: SushiBeltTrackerProtocol
  private let sushiBeltDebugger: SushiBeltDebuggerLogic
  private var items = Set<VisibleStateDetectorItem>()
  private var trackingRectProvider: (() -> CGRect)?

  init(
    sushiBeltTracker: SushiBeltTrackerProtocol,
    sushiBeltDebugger: SushiBeltDebuggerLogic,
  ) {
    self.sushiBeltTracker = sushiBeltTracker
    self.sushiBeltDebugger = sushiBeltDebugger
    sushiBeltTracker.dataSource = self
    sushiBeltTracker.delegate = self
  }

  func detect(items: [VisibleStateDetectorItem], trackingRect: @escaping () -> CGRect) {
    self.items = Set(items)
    trackingRectProvider = trackingRect

    let sushiBeltTrackerItems = self.items.compactMap {
      if !trackingRect().intersection($0.target.frameInWindow).isEmpty {
        SushiBeltTrackerItem(
          id: .trackingIdentifier($0),
          rect: .init(frame: $0.target.frameInWindow),
        )
      } else {
        nil
      }
    }
    sushiBeltTracker.calculateItemsIfNeeded(items: sushiBeltTrackerItems)

    detectInnerScrollable()
  }

  func clear() {
    for item in items {
      (item.target as? ImpressionInnerScrollable)?.clearImpressionEvent()
    }
    items = []
    sushiBeltTracker.calculateItemsIfNeeded(items: [])
  }

  func showDebugger() {
    sushiBeltTracker.registerDebugger(debugger: sushiBeltDebugger)
    sushiBeltDebugger.show()
  }

  private func detectInnerScrollable() {
    for item in items {
      (item.target as? ImpressionInnerScrollable)?.trackImpressionEvent()
    }
  }
}

extension VisibleStateDetector: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    trackingRectProvider?() ?? .zero
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard
      case .trackingIdentifier(let id) = item.id,
      let item = items.first(where: { $0.trackingIdentifer == id.trackingIdentifer })
    else {
      return .zero
    }
    return item.ratio
  }
}

extension VisibleStateDetector: SushiBeltTrackerDelegate {

  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    // nothing
  }

  func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    guard
      case .trackingIdentifier(let id) = item.id,
      let item = items.first(where: { $0.trackingIdentifer == id.trackingIdentifer })
    else {
      return
    }
    delegate?.onDetect(visibleItem: item)
    (item.target as? ImpressionInnerScrollable)?.trackImpressionEvent()
  }

  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    guard
      case .trackingIdentifier(let id) = item.id,
      let item = items.first(where: { $0.trackingIdentifer == id.trackingIdentifer })?
        .target as? ImpressionInnerScrollable
    else {
      return
    }

    item.clearImpressionEvent()
  }
}

