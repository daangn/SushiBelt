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

  private let mapper: (UIView) -> VisibleStateDetectorItem?
  private let viewabilityMapper: (UIView) -> ViewabilityItem?

  public convenience init(mapper: @escaping (UIView) -> VisibleStateDetectorItem?) {
    self.init(mapper: mapper, viewabilityMapper: { _ in nil })
  }

  /// Maps each visible cell to independent impression and viewability registrations.
  public init(
    mapper: @escaping (UIView) -> VisibleStateDetectorItem?,
    viewabilityMapper: @escaping (UIView) -> ViewabilityItem?
  ) {
    self.mapper = mapper
    self.viewabilityMapper = viewabilityMapper
  }

  public func makeVisibleDetectorItems(view: UIScrollView) -> [VisibleStateDetectorItem] {
    visibleCells(in: view).compactMap(mapper)
  }

  public func makeViewabilityItems(view: UIScrollView) -> [ViewabilityItem] {
    visibleCells(in: view).compactMap(viewabilityMapper)
  }

  private func visibleCells(in view: UIScrollView) -> [UIView] {
    switch view {
    case let tableView as UITableView:
      tableView.visibleCells

    case let collectionView as UICollectionView:
      collectionView.visibleCells

    default:
      []
    }
  }
}
