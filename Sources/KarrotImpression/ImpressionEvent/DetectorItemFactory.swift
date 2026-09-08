//
//  DetectorItemFactory.swift
//  KarrotImpressionInterface
//
//  Created by Jaxtyn on 2023/07/20.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// @mockable
/// 추적하려는 아이템들을 만드는 팩토리 타입
public protocol DetectorItemFactory {

  ///
  ///   주어진 `UIScrollView`로 추적하려는 아이템들을 만드는 팩토리 메소드
  ///
  /// - Parameters:
  ///   - view: Visible Views를 포함하는 컨테이너 뷰
  func makeVisibleDetectorItems(view: UIScrollView) -> [VisibleStateDetectorItem]
}

