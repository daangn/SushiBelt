//
//  VisibleStateDetectorDelegate.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// @mockable
protocol VisibleStateDetectorDelegate: AnyObject {

  func onDetect(visibleItem: VisibleStateDetectorItem)
}

