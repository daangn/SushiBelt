//
//  ImpressionInnerScrollable.swift
//  KarrotImpressionInterface
//
//  Created by Jaxtyn on 2023/07/24.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// @mockable
/// 추적하려는 Target 내부에 다시 ScrollView를 가지고 있는 경우를 지원하기 위한 타입
public protocol ImpressionInnerScrollable {

  /// 화면에 보여질 때 호출되는 메소드
  func trackImpressionEvent()

  /// 화면에 사라질 때 호출되는 메소드
  func clearImpressionEvent()
}

