//
//  DetectorItemFactory.swift
//  KarrotImpression
//
//  Created by Jaxtyn on 2023/07/20.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// @mockable
/// Creates the items to evaluate during an impression detection pass.
public protocol DetectorItemFactory {

  /// Returns tracking items for the supplied scroll view.
  ///
  /// - Parameters:
  ///   - view: The scroll view containing the target views.
  func makeVisibleDetectorItems(view: UIScrollView) -> [VisibleStateDetectorItem]
}
