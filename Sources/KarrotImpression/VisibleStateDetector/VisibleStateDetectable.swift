//
//  VisibleStateDetectable.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// @mockable
/// Detects when scroll view items meet their visibility thresholds.
protocol VisibleStateDetectable: AnyObject {

  var delegate: VisibleStateDetectorDelegate? { get set }

  /// Evaluates the supplied items against the tracking area.
  ///
  /// - Note: Reports detected items through the delegate's `onDetect(visibleItem:)` method.
  ///
  /// - Parameters:
  ///   - items: The items to evaluate.
  ///   - trackingRect: Returns the tracking area in window coordinates.
  func detect(items: [VisibleStateDetectorItem], trackingRect: @escaping () -> CGRect)

  /// Clears tracked-item state.
  func clear()

  /// Shows the item debugger.
  func showDebugger()
}
