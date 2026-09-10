//
//  ImpressionDetectorTarget.swift
//  KarrotImpression
//
//  Created by Jaxtyn on 2023/07/21.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// @mockable
/// A view or other object whose visible frame can be tracked.
public protocol ImpressionDetectorTarget {

  /// The target's current frame in window coordinates.
  var frameInWindow: CGRect { get }
}

extension ImpressionDetectorTarget where Self: UIView {
  public var frameInWindow: CGRect {
    convert(bounds, to: nil)
  }
}

extension UIView: ImpressionDetectorTarget {}
