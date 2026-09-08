//
//  Created by jamie hyeon on 3/23/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// @mockable
public protocol ImpressionCooltimeCache {
  func isInCooltime(for key: String, coolingTime: TimeInterval) -> Bool
  func clear()
}

