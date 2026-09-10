//
//  ImpressionEventTrackable.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// Returns whether a detected item is eligible for an impression callback.
public typealias ImpressionItemFilter = (VisibleStateDetectorItem) -> Bool

/// Handles an item that has met the impression criteria.
public typealias ImpressionEventCallback = (VisibleStateDetectorItem) -> Void

/// @mockable
/// Tracks impressions for items in a scroll view.
public protocol ImpressionEventTrackable {

  /// Registers a scroll view and observes its owning view controller's lifecycle.
  ///
  /// - Parameters:
  ///   - viewController: The view controller that owns the scroll view.
  ///   - scrollView: The scroll view containing the tracked items.
  ///   - detectorItemFactory: Creates the items to evaluate on each detection pass.
  ///   - trackingRect: Returns the tracking area in window coordinates.
  ///
  /// - Note: Use this overload for a screen-level scroll view. The tracker
  /// reevaluates items when the view appears or the app becomes active.
  func register(
    viewController: UIViewController,
    scrollView: UIScrollView,
    detectorItemFactory: DetectorItemFactory,
    trackingRect: @escaping (() -> CGRect),
  )

  /// Registers a scroll view without observing a view controller's lifecycle.
  ///
  /// - Parameters:
  ///   - scrollView: The scroll view containing the tracked items.
  ///   - detectorItemFactory: Creates the items to evaluate on each detection pass.
  ///   - trackingRect: Returns the tracking area in window coordinates.
  ///
  /// - Note: Use this overload for nested scroll views, such as a carousel inside
  /// a cell. A parent target can implement `ImpressionInnerScrollable` to forward
  /// tracking and clearing requests to its nested tracker.
  func register(
    scrollView: UIScrollView,
    detectorItemFactory: DetectorItemFactory,
    trackingRect: @escaping (() -> CGRect),
  )

  /// Sets a filter that runs before the cooldown check and impression callback.
  ///
  /// - Parameter filter: Return `false` to suppress the item's callback.
  func setFilter(_ filter: @escaping ImpressionItemFilter)

  /// Sets the callback for detected impressions, replacing any previous callback.
  ///
  /// - Parameter callback: Handles an item that passes the filter and cooldown check.
  func subscribe(callback: @escaping ImpressionEventCallback)

  /// Evaluates the registered scroll view's items without waiting for a scroll event.
  ///
  /// - Note: After reloading a table or collection view, call this once layout
  /// has updated the visible cells and their frames.
  /// - Parameter shouldResetCache: Whether to clear tracked-item state first.
  /// This does not clear the cooldown cache.
  func trackManually(shouldResetCache: Bool)

  /// Clears tracked-item state without clearing the cooldown cache.
  ///
  /// Use this before reevaluating a refreshed list to let the same items produce
  /// new callbacks, subject to their cooldowns.
  func clearCache()

  /// Shows the UIKit item debugger. Call only from debug-only application code.
  func enableDebugging()
}
