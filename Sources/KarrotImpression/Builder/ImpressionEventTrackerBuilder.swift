//
//  ImpressionEventTrackerBuilder.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/14.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

public final class ImpressionEventTrackerBuilder: ImpressionEventTrackerBuildable {

  private let usesInitialVisibility: Bool

  /// - Parameters:
  ///   - usesInitialVisibility: Seeds the visibility of a registered view controller from the
  ///   window attachment of its view. Turn this on to keep tracking a screen that was already
  ///   onscreen when it registered. Defaults to `false`.
  public init(usesInitialVisibility: Bool = false) {
    self.usesInitialVisibility = usesInitialVisibility
  }

  public func build() -> any ImpressionEventTrackable {
    build(cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }))
  }

  public func build(cooltimeCache: ImpressionCooltimeCache) -> any ImpressionEventTrackable {
    ImpressionEventTracker(
      detector: VisibleStateDetector(
        sushiBeltTracker: SushiBeltTracker(),
        sushiBeltDebugger: SushiBeltDebugger.shared,
      ),
      application: UIApplication.self,
      cooltimeCache: cooltimeCache,
      usesInitialVisibility: usesInitialVisibility,
    )
  }
}

