//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

// MARK: - ImpressionEntry

/// 자식 뷰가 컨테이너에 가시성 상태를 보고하기 위한 엔트리.
///
/// `Hashable` 및 `Equatable` 비교에서 `onImpressionEnter`·`onImpressionExit` 클로저는 제외됩니다.
struct ImpressionEntry: Hashable {
  let item: ImpressionItem
  let isVisible: Bool
  let onImpressionEnter: () -> Void
  let onImpressionExit: (() -> Void)?

  func hash(into hasher: inout Hasher) {
    hasher.combine(item.id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.item == rhs.item && lhs.isVisible == rhs.isVisible
  }
}

// MARK: - ImpressionVisibilityPreferenceKey

/// 자식 뷰들의 가시성 상태를 컨테이너로 전달하는 PreferenceKey.
struct ImpressionVisibilityPreferenceKey: PreferenceKey {
  static let defaultValue: Set<ImpressionEntry> = []

  static func reduce(
    value: inout Set<ImpressionEntry>,
    nextValue: () -> Set<ImpressionEntry>,
  ) {
    value.formUnion(nextValue())
  }
}

