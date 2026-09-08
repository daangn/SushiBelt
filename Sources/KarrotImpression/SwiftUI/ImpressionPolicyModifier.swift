//
//  Created by Daangn Jaxtyn on 4/9/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

/// `ImpressionPolicy`를 Environment로 주입하는 modifier.
///
/// `@State`로 `Storage`를 보존하고, `policy.id` 변경을 감지하여
/// 필요 시 새 `Storage`를 생성합니다.
///
/// `policy` 자체는 매 body 재계산마다 최신 값이 반영되므로,
/// `init` 파라미터 변경은 즉시 적용됩니다.
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

