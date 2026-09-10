//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

// MARK: - View Extensions

extension View {

  /// Creates a container for descendant views registered with `.impressionTrackable()`.
  ///
  /// The container manages its visible bounds and tracking activity in response
  /// to view and app lifecycle events.
  ///
  /// ```swift
  /// List {
  ///   ForEach(items, id: \.self) { item in
  ///     Text(item)
  ///       .impressionTrackable(id: item) {
  ///         print("Impression: \(item)")
  ///       }
  ///   }
  /// }
  /// .impressionTrackableContainer()
  /// .impressionPolicy(.cooldown(interval: 30))
  /// ```
  ///
  /// - Parameter visibleArea: The region used for visibility checks. Defaults to `.ignoringSafeArea()`.
  public func impressionTrackableContainer(
    visibleArea: VisibleAreaRegion = .ignoringSafeArea()
  ) -> some View {
    modifier(
      ImpressionTrackingContainerModifier(visibleArea: visibleArea)
    )
  }

  /// Supplies a policy that decides whether new impressions are allowed.
  ///
  /// Policy storage is preserved while `policy.id` stays the same and resets
  /// when the ID changes. The policy value itself updates with the view.
  ///
  /// - Parameter policy: The impression policy.
  public func impressionPolicy(_ policy: some ImpressionPolicy) -> some View {
    modifier(ImpressionPolicyModifier(policy: policy))
  }

  /// Registers this view for impression tracking inside an `.impressionTrackableContainer()`.
  ///
  /// A view is visible when its visible area is positive and its visible fraction
  /// meets `visibilityThreshold`. New visible entries fire impressions if the policy
  /// allows them. Leaving and reentering the visible region can produce another impression.
  ///
  /// With `tracksExit` enabled, an item whose entry fired receives `onImpressionExit`
  /// when it stops meeting the visibility requirement or leaves the visible set.
  /// Outstanding exits are also emitted on a best-effort basis when the container
  /// becomes inactive, such as when the app enters the background or the view disappears.
  ///
  /// - Parameters:
  ///   - id: The tracked item's unique identifier.
  ///   - visibilityThreshold: The minimum visible fraction, clamped to `0...1`. Defaults to `0.0`.
  ///   - tracksExit: Whether to track exits. Defaults to `false`.
  ///   - onImpressionEnter: Called when an impression is allowed for a new visible entry.
  ///   - onImpressionExit: Called when an entered item exits, if `tracksExit` is `true`.
  public func impressionTrackable(
    id: some Hashable,
    visibilityThreshold: CGFloat = 0.0,
    tracksExit: Bool = false,
    onImpressionEnter: @escaping () -> Void,
    onImpressionExit: (() -> Void)? = nil,
  ) -> some View {
    modifier(
      ImpressionTrackableModifier(
        item: ImpressionItem(
          id: id,
          visibilityThreshold: visibilityThreshold,
          tracksExit: tracksExit,
        ),
        onImpressionEnter: onImpressionEnter,
        onImpressionExit: onImpressionExit,
      )
    )
  }

  /// Registers this view for impression tracking with a preconfigured `ImpressionItem`.
  ///
  /// An item whose entry fired also receives `onImpressionExit` when it exits
  /// if `item.tracksExit` is `true`.
  ///
  /// - Parameters:
  ///   - item: The item's identity, visibility threshold, and exit-tracking option.
  ///   - onImpressionEnter: Called when an impression is allowed for a new visible entry.
  ///   - onImpressionExit: Called when an entered item exits, if `item.tracksExit` is `true`.
  public func impressionTrackable(
    item: ImpressionItem,
    onImpressionEnter: @escaping () -> Void,
    onImpressionExit: (() -> Void)? = nil,
  ) -> some View {
    modifier(
      ImpressionTrackableModifier(
        item: item,
        onImpressionEnter: onImpressionEnter,
        onImpressionExit: onImpressionExit,
      )
    )
  }
}

