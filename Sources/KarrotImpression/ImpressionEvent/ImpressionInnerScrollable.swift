//
//  ImpressionInnerScrollable.swift
//  KarrotImpression
//
//  Created by Jaxtyn on 2023/07/24.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// @mockable
/// Forwards a parent target's tracking requests to a nested scroll view.
public protocol ImpressionInnerScrollable {

  /// Requests an impression check for the nested scroll view.
  func trackImpressionEvent()

  /// Requests that the nested tracker clear its tracked-item state.
  func clearImpressionEvent()
}
