//
//  SushiBeltTrackerDataSourceStub.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

@testable import SushiBelt

final class SushiBeltTrackerDataSourceStub: SushiBeltTrackerDataSource {
  
  var trackingRectStub: CGRect = .zero
  
  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.trackingRectStub
  }
  
  var visibleRatioForItemStub: CGFloat = 0.0
  
  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    return self.visibleRatioForItemStub
  }
  
}
