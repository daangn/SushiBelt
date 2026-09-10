//
//  ImpressionEventTrackerBuilder.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/14.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

public final class ImpressionEventTrackerBuilder: ImpressionEventTrackerBuildable {

  public init() {}

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
    )
  }
}

