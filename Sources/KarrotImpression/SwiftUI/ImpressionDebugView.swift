//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

public extension View {

  /// 하위의 `.impressionTrackable()` 아이템들에 가시 상태를 나타내는 색상 오버레이를 표시합니다.
  ///
  /// DEBUG 빌드에서만 동작하며, 릴리즈 빌드에서는 완전히 제거됩니다.
  /// - 가시 상태: 초록색 반투명 오버레이 + border
  /// - 비가시 상태: 빨간색 반투명 오버레이 + border
  ///
  /// ```swift
  /// List { ... }
  ///   .impressionTrackableContainer()
  ///   .showsChildrenImpressionRect()
  /// ```
  func showsChildrenImpressionRect() -> some View {
#if DEBUG
    environment(\.showsImpressionRect, true)
#else
    self
#endif
  }
}

extension View {

  /// 개별 아이템에 가시 상태 오버레이를 적용합니다. (내부 전용)
  func showsImpressionRect(isVisible: Bool) -> some View {
#if DEBUG
    modifier(ShowsImpressionRectModifier(isVisible: isVisible))
#else
    self
#endif
  }
}

#if DEBUG
extension EnvironmentValues {
  @Entry var showsImpressionRect: Bool = false
}

/// 가시 상태에 따라 색상 오버레이를 표시하는 디버그용 modifier.
private struct ShowsImpressionRectModifier: ViewModifier {
  let isVisible: Bool
  @Environment(\.showsImpressionRect) private var showsImpressionRect

  func body(content: Content) -> some View {
    if showsImpressionRect {
      let color: Color = isVisible ? .green : .red
      content
        .overlay {
          color.opacity(0.2)
            .border(color, width: 1)
            .allowsHitTesting(false)
        }
    } else {
      content
    }
  }
}
#endif

