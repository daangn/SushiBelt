//
//  MainTestKind.swift
//  SushiBelt_Example
//
//  Created by david on 2022/11/06.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

enum MainTestKind: Int, CaseIterable {
  case single
  case scroll
  case tile
  case matrix

  var image: UIImage? {
    switch self {
    case .single:
      return UIImage(named: "red_sushi")
    case .scroll:
      return UIImage(named: "orange_sushi")
    case .tile:
      return UIImage(named: "egg_sushi")
    case .matrix:
      return UIImage(named: "red_sushi")
    }
  }

  var visibleRatio: CGFloat {
    switch self {
    case .single:
      return 0.2
    case .scroll:
      return 0.5
    case .tile:
      return 0.8
    case .matrix:
      return 0.2
    }
  }

  var title: String {
    switch self {
    case .single:
      return "Single List"
    case .scroll:
      return "ScrollView"
    case .tile:
      return "Tile List"
    case .matrix:
      return "Matrix"
    }
  }
}
