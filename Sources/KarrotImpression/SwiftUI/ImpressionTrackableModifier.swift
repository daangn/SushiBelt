//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

/// Measures an item's visible fraction and reports it to the tracking container.
///
/// An active item is visible when its intersection with `impressionContainerFrame`
/// has positive area and its visible fraction meets `visibilityThreshold`.
/// `onAppear` and `onDisappear` control the item's active state. Reports travel
/// through `ImpressionVisibilityPreferenceKey`; the container decides whether to fire callbacks.
struct ImpressionTrackableModifier: ViewModifier {

  let item: ImpressionItem
  let onImpressionEnter: () -> Void
  var onImpressionExit: (() -> Void)? = nil
  @State private var isActive = false
  @State private var isVisible = false
  @Environment(\.impressionContainerFrame) private var containerFrame
  #if DEBUG
  @Environment(\.impressedItemIDs) private var impressedItemIDs
  #endif

  func body(content: Content) -> some View {
    content
      .onAppear {
        isActive = true
      }
      .onDisappear {
        isActive = false
        isVisible = false
      }
      .onGeometryChange(for: Bool.self) { proxy in
        guard isActive else { return false }

        let frame = proxy.frame(in: .global)
        let visibleRatio = visibleRatio(
          frame: frame,
          containerFrame: containerFrame,
        )
        return visibleRatio > 0 && visibleRatio >= item.visibilityThreshold
      } action: { newValue in
        isVisible = newValue
      }
      .preference(
        key: ImpressionVisibilityPreferenceKey.self,
        value: [
          ImpressionEntry(
            item: item,
            isVisible: isVisible,
            onImpressionEnter: onImpressionEnter,
            onImpressionExit: onImpressionExit,
          )
        ] as Set,
      )
    #if DEBUG
      .showsImpressionRect(isVisible: impressedItemIDs.contains(item.id))
    #endif
  }

  /// Returns the fraction of the item's area inside the container's visible bounds.
  private func visibleRatio(frame: CGRect, containerFrame: CGRect) -> CGFloat {
    let itemArea = frame.width * frame.height
    if itemArea == .zero {
      return .zero
    }

    let intersection = containerFrame.intersection(frame)
    if intersection.isEmpty {
      return .zero
    }

    return (intersection.width * intersection.height) / itemArea
  }
}

