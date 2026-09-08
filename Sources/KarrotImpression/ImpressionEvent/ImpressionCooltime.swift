//
//  Created by Jamie.hyeon on 7/24/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// 아이템에 적용할 임프레션 쿨타임 정보예요.
public struct ImpressionCooltime: Hashable {

  /// 쿨타임 캐시를 판정할 키예요.
  public let key: String

  /// 이 아이템에 적용할 쿨타임(초)이에요.
  public let coolingTime: TimeInterval

  public init(
    key: String,
    coolingTime: TimeInterval,
  ) {
    self.key = key
    self.coolingTime = coolingTime
  }
}

