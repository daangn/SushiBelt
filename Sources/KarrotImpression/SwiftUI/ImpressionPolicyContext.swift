//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

// MARK: - ImpressionPolicyContext

/// Type-erases a policy and its storage binding for the SwiftUI environment.
struct ImpressionPolicyContext {

  private let id: AnyHashable
  private let allowsImpressionHandler: (AnyHashable) -> Bool

  init<P: ImpressionPolicy>(policy: P, storage: Binding<P.Storage>) {
    self.id = policy.id
    allowsImpressionHandler = { id in
      // Pass the bound value as inout so policy updates reach the original storage.
      policy.allowsImpression(for: id, storage: &storage.wrappedValue)
    }
  }

  func allowsImpression(for id: AnyHashable) -> Bool {
    allowsImpressionHandler(id)
  }
}

