//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {

  /// 컨테이너의 가시 영역 (global 좌표계).
  @Entry var impressionContainerFrame: CGRect = .zero

  /// 임프레션 허용 여부를 결정하는 정책 컨텍스트.
  ///
  /// `ImpressionPolicyModifier`가 `ImpressionPolicy`와 `Storage`를 캡처하여 생성합니다.
  /// `.impressionPolicy()` modifier를 통해 주입됩니다.
  @Entry var impressionPolicyContext: ImpressionPolicyContext? = nil

#if DEBUG
  /// 실제 임프레션이 발생한 아이템 ID 집합. 디버그 오버레이 전용.
  @Entry var impressedItemIDs: Set<AnyHashable> = []
#endif
}

