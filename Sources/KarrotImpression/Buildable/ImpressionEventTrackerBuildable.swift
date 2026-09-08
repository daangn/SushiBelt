//
//  ImpressionEventTrackerBuildable.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/14.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// @mockable
public protocol ImpressionEventTrackerBuildable {

  func build() -> any ImpressionEventTrackable
  func build(cooltimeCache: ImpressionCooltimeCache) -> any ImpressionEventTrackable
}
