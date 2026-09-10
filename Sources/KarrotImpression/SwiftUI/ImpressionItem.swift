//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// An item to track for impressions.
///
/// Groups an item's identity, visibility threshold, and exit-tracking option for
/// `impressionTrackable(item:onImpressionEnter:onImpressionExit:)`.
public struct ImpressionItem: Hashable {

  /// The tracked item's unique identifier.
  public let id: AnyHashable

  /// The minimum visible fraction required for an impression, clamped to `0...1`.
  ///
  /// A value of `0.5` requires at least half the item's area to be visible.
  /// A value of `0.0` still requires a positive visible area.
  public let visibilityThreshold: CGFloat

  /// Whether to call `onImpressionExit` when an entered item stops being visible.
  ///
  /// Defaults to `false`, which tracks entries without exit callbacks. When `true`,
  /// an item whose entry callback fired also receives an exit callback when it no
  /// longer meets the visibility threshold or leaves the visible set.
  public let tracksExit: Bool

  public init(
    id: some Hashable,
    visibilityThreshold: CGFloat,
    tracksExit: Bool = false,
  ) {
    self.id = AnyHashable(id)
    self.visibilityThreshold = min(max(visibilityThreshold, 0.0), 1.0)
    self.tracksExit = tracksExit
  }
}

