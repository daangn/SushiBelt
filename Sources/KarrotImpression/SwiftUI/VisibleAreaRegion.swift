//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

/// Defines the container region used for impression visibility checks.
///
/// Pass this value as the container's `visibleArea` to choose which safe area
/// insets to respect when measuring visible bounds.
///
/// ```swift
/// // Extend the visible region by ignoring all safe areas (the default).
/// .impressionTrackableContainer(visibleArea: .ignoringSafeArea())
///
/// // Keep the visible region within the safe area.
/// .impressionTrackableContainer(visibleArea: .safeArea)
///
/// // Ignore safe area insets on selected edges.
/// .impressionTrackableContainer(visibleArea: .ignoringSafeArea(edges: .bottom))
/// ```
public enum VisibleAreaRegion {

  /// Keeps the visible region within the safe area.
  case safeArea

  /// Extends the visible region by ignoring the selected safe areas.
  ///
  /// Uses SwiftUI's `ignoresSafeArea(_:edges:)`. Defaults to all regions and edges.
  case ignoringSafeArea(regions: SafeAreaRegions = .all, edges: Edge.Set = .all)

  /// The regions passed to `ignoresSafeArea`.
  public var safeAreaRegions: SafeAreaRegions {
    switch self {
    case .safeArea: .all
    case .ignoringSafeArea(let regions, _): regions
    }
  }

  /// The edges passed to `ignoresSafeArea`.
  public var safeAreaEdges: Edge.Set {
    switch self {
    case .safeArea: []
    case .ignoringSafeArea(_, let edges): edges
    }
  }
}

