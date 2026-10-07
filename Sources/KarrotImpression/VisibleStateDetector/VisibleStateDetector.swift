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
  private let impressionHandler = ImpressionHandler()
  private let viewableImpressionHandler = ViewableImpressionHandler()
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

  func detect(
    items: [VisibleStateDetectorItem],
    viewabilityItems: [ViewabilityItem],
    trackingRect: @escaping () -> CGRect
  ) {
    trackingRectProvider = trackingRect
    impressionHandler.update(items: items)
    viewableImpressionHandler.update(items: viewabilityItems)

    let viewport = trackingRect()
    let sushiBeltTrackerItems = impressionHandler.makeTrackerItems(viewport: viewport)
      + viewableImpressionHandler.makeTrackerItems(viewport: viewport)
    sushiBeltTracker.calculateItemsIfNeeded(items: sushiBeltTrackerItems)
    impressionHandler.evaluate(delegate: delegate)
  }

  func clear() {
    impressionHandler.clear(delegate: delegate)
    viewableImpressionHandler.clear()
    sushiBeltTracker.calculateItemsIfNeeded(items: [])
  }

  func showDebugger() {
    sushiBeltTracker.registerDebugger(debugger: sushiBeltDebugger)
    sushiBeltDebugger.show()
  }

  private func trackingItem(for item: SushiBeltTrackerItem) -> (any TrackingItem)? {
    guard case .trackingIdentifier(let identifier) = item.id else { return nil }
    return identifier as? any TrackingItem
  }
}

extension VisibleStateDetector: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    trackingRectProvider?() ?? .zero
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    trackingItem(for: item)?.ratio ?? .zero
  }
}

extension VisibleStateDetector: SushiBeltTrackerDelegate {

  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    // nothing
  }

  func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    trackingItem(for: item)?.receive(.entered, delegate: delegate)
  }

  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    trackingItem(for: item)?.receive(.ended, delegate: delegate)
  }

  func didExit(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    trackingItem(for: item)?.receive(.exited, delegate: delegate)
  }
}
