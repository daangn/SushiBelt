//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {

  /// The container's visible bounds in the global coordinate space.
  @Entry var impressionContainerFrame: CGRect = .zero

  /// The policy context used to decide whether an impression is allowed.
  ///
  /// Supplied by `.impressionPolicy()`, which captures the policy and its storage binding.
  @Entry var impressionPolicyContext: ImpressionPolicyContext? = nil

#if DEBUG
  /// IDs in the last processed visible snapshot, including policy-suppressed items.
  /// Used only by the debug overlay; this is not a record of fired callbacks.
  @Entry var impressedItemIDs: Set<AnyHashable> = []
#endif
}

