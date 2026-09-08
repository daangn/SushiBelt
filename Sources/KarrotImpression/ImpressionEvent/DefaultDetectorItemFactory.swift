//
//  DefaultDetectorItemFactory.swift
//  KarrotImpressionInterface
//
//  Created by Jaxtyn on 2023/07/20.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// UICollectionView / UITableView를 지원하는 기본적인 Factory 구현체
public final class DefaultDetectorItemFactory: DetectorItemFactory {

  /// Cell to ImpressionItem를 만들어주는 mapper 클로저
  private let mapper: (UIView) -> VisibleStateDetectorItem?

  public init(mapper: @escaping (UIView) -> VisibleStateDetectorItem?) {
    self.mapper = mapper
  }

  public func makeVisibleDetectorItems(view: UIScrollView) -> [VisibleStateDetectorItem] {
    switch view {
    case let tableView as UITableView:
      tableView.visibleCells.compactMap { cell in
        mapper(cell)
      }

    case let collectionView as UICollectionView:
      collectionView.visibleCells.compactMap { cell in
        mapper(cell)
      }

    default:
      []
    }
  }
}

