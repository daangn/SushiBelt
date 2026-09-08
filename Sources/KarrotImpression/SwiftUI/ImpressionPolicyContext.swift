//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

// MARK: - ImpressionPolicyContext

/// `ImpressionPolicy`와 `Storage`를 type-erase하여 Environment로 전달하기 위한 컨텍스트.
struct ImpressionPolicyContext {

  private let id: AnyHashable
  private let allowsImpressionHandler: (AnyHashable) -> Bool

  init<P: ImpressionPolicy>(policy: P, storage: Binding<P.Storage>) {
    self.id = policy.id
    allowsImpressionHandler = { id in
      // Binding의 wrappedValue를 inout으로 전달하여,
      // Policy가 원본 Storage의 값을 직접 변경할 수 있도록 합니다.
      policy.allowsImpression(for: id, storage: &storage.wrappedValue)
    }
  }

  func allowsImpression(for id: AnyHashable) -> Bool {
    allowsImpressionHandler(id)
  }
}

