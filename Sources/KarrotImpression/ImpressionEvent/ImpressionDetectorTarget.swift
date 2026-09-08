//
//  ImpressionDetectorTarget.swift
//  KarrotImpressionInterface
//
//  Created by Jaxtyn on 2023/07/21.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// @mockable
/// 추적하려는 타겟 (e.g. View, Cell, Node, ...)
public protocol ImpressionDetectorTarget {

  /// 윈도우에서 현재 위치 및 크기 정보를 표현하는 값
  var frameInWindow: CGRect { get }
}

extension ImpressionDetectorTarget where Self: UIView {
  public var frameInWindow: CGRect {
    convert(bounds, to: nil)
  }
}

extension UIView: ImpressionDetectorTarget {}

