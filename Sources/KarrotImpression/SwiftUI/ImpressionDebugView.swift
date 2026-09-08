//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

public extension View {

  /// Shows colored overlays for descendant `.impressionTrackable()` items.
  ///
  /// Available in `DEBUG` builds; this modifier is a no-op in release builds.
  /// - Green: The item's ID is in the container's last processed visible snapshot.
  /// - Red: The item's ID is absent from that snapshot.
  ///
  /// The snapshot includes policy-suppressed items, so green does not confirm
  /// that an impression callback fired.
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

  /// Applies a debug overlay using the item's presence in the processed snapshot.
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

/// Draws a colored overlay for the supplied debug state.
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

