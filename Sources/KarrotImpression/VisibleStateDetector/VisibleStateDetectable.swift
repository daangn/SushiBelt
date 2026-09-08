//
//  VisibleStateDetectable.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// @mockable
/// `UIScrollView` 서브뷰들의 Visible 상태를 감지하는 프로토콜
protocol VisibleStateDetectable: AnyObject {

  var delegate: VisibleStateDetectorDelegate? { get set }

  /// 주어진 `items`의 Visible 상태 감지를 요청해요.
  ///
  /// - Note: `VisibleStateDetectorDelegate`의 `onDetect(visibleItem: VisibleStateDetectorItem)`
  /// 함수를 통해 감지된 `items`를 콜백받을 수 있어요.
  ///
  /// - Parameters:
  ///   - items: 감지할 `VisibleStateDetectorItem`의 배열
  ///   - trackingRect: 감지 영역을 반환하는 클로저
  func detect(items: [VisibleStateDetectorItem], trackingRect: @escaping () -> CGRect)

  /// 감지된 아이템을 초기화해요.
  func clear()

  /// 디버거를 노출해요.
  func showDebugger()
}

