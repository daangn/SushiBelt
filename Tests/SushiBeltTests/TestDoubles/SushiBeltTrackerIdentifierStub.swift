//
//  SushiBeltTrackerIdentifierStub.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation

@testable import SushiBelt

final class SushiBeltTrackerIdentifierStub: SushiBeltTrackerIdentifier {
  
  var trackingIdentifer: String = ""
  
  init(trackingIdentifer: String) {
    self.trackingIdentifer = trackingIdentifer
  }
}
