//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

// MARK: - ImpressionEntry

/// A child view's visibility report to its tracking container.
///
/// Equality and hashing exclude the enter and exit closures.
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

/// Collects child visibility reports for the tracking container.
struct ImpressionVisibilityPreferenceKey: PreferenceKey {
  static let defaultValue: Set<ImpressionEntry> = []

  static func reduce(
    value: inout Set<ImpressionEntry>,
    nextValue: () -> Set<ImpressionEntry>,
  ) {
    value.formUnion(nextValue())
  }
}

