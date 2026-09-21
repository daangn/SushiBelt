//
//  DetectorItemFactoryStub.swift
//  SushiBeltTests
//
//  Created by 1Consumption on 2026/09/18.
//

import UIKit
@testable import KarrotImpression

final class DetectorItemFactoryStub: DetectorItemFactory {

  var items: [VisibleStateDetectorItem] = []

  func makeVisibleDetectorItems(view: UIScrollView) -> [VisibleStateDetectorItem] {
    self.items
  }
}
