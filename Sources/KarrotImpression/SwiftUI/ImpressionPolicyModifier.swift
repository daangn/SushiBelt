//
//  Created by Daangn Jaxtyn on 4/9/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

/// Supplies an impression policy through the SwiftUI environment.
///
/// Keeps `Storage` in `@State` and resets it when `policy.id` changes.
///
/// The policy value itself is refreshed on each body update, so configuration
/// changes take effect without requiring a new storage identity.
struct ImpressionPolicyModifier<P: ImpressionPolicy>: ViewModifier {
  let policy: P
  @State private var storage: P.Storage = P.makeStorage()

  init(policy: P) {
    self.policy = policy
  }

  func body(content: Content) -> some View {
    content
      .environment(\.impressionPolicyContext, ImpressionPolicyContext(policy: policy, storage: $storage))
      .onChange(of: policy.id) { _ in
        storage = P.makeStorage()
      }
  }
}

