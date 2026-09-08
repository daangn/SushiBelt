//
//  DefaultDetectorItemFactory.swift
//  KarrotImpression
//
//  Created by Jaxtyn on 2023/07/20.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// Maps visible cells in a table or collection view to tracking items.
/// Other scroll view types produce no items; use a custom `DetectorItemFactory` for them.
public final class DefaultDetectorItemFactory: DetectorItemFactory {

  /// Maps a visible cell to an item, or returns `nil` to exclude it.
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
