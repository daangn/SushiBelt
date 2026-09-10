//
//  SushiBeltTrackerProtocol.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/15.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// @mockable
protocol SushiBeltTrackerProtocol: AnyObject {

  var delegate: SushiBeltTrackerDelegate? { get set }
  var dataSource: SushiBeltTrackerDataSource? { get set }

  func calculateItemsIfNeeded(items: [SushiBeltTrackerItem])
  func registerDebugger(debugger: SushiBeltDebuggerLogic)
}

extension SushiBeltTracker: SushiBeltTrackerProtocol {}

