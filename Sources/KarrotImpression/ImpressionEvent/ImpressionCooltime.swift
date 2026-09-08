//
//  Created by Jamie.hyeon on 7/24/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// Configures the cooldown for a UIKit impression item.
public struct ImpressionCooltime: Hashable {

  /// The cache key used to suppress repeated impressions.
  public let key: String

  /// The cooldown duration, in seconds.
  public let coolingTime: TimeInterval

  public init(
    key: String,
    coolingTime: TimeInterval,
  ) {
    self.key = key
    self.coolingTime = coolingTime
  }
}
