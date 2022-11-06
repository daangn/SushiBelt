//
//  Sushi.swift
//  SushiBelt_Example
//
//  Created by david on 2022/11/06.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

import UIKit

struct Sushi {

  enum Kind: String, CaseIterable {
    case red = "red_sushi"
    case orange = "orange_sushi"
    case egg = "egg_sushi"

    var visibleRatio: CGFloat {
      switch self {
      case .red:
        return 0.2
      case .orange:
        return 0.5
      case .egg:
        return 0.8
      }
    }
  }

  let tag: Int
  let kind: Kind
  let image: UIImage?

  static func いらっしゃいませ(count: Int) -> [Sushi] {
    return (0 ..< count).map { index in
      let kind = Kind.allCases.randomElement() ?? .red
      return Sushi(
        tag: index,
        kind: kind,
        image: UIImage(named: kind.rawValue)
      )
    }
  }
}
