//
//  VisibleStateDetectorItem.swift
//  KarrotImpressionInterface
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// 추적에 필요한 정보를 담고 있는 구조체
public struct VisibleStateDetectorItem: Identifiable, Hashable {

  public let id: String
  public let target: ImpressionDetectorTarget
  public let ratio: CGFloat
  public let userInfo: [AnyHashable: Any]?

  /// 이 아이템에 적용할 쿨타임 정보예요.
  ///
  /// `nil`이면 이 아이템은 쿨타임을 적용받지 않아요 (`id` 폴백이 아니라 명시적으로 미적용).
  /// 한 화면에 쿨타임 대상과 비대상이 섞여 있을 수 있어요.
  public let cooltime: ImpressionCooltime?

  public init(
    id: String,
    target: ImpressionDetectorTarget,
    ratio: CGFloat,
    userInfo: [AnyHashable: Any]? = nil,
    cooltime: ImpressionCooltime? = nil,
  ) {
    self.id = id
    self.target = target
    self.ratio = ratio
    self.userInfo = userInfo
    self.cooltime = cooltime
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: VisibleStateDetectorItem, rhs: VisibleStateDetectorItem) -> Bool {
    lhs.id == rhs.id
  }
}

