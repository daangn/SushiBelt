//
//  MatrixViewController.swift
//  SushiBelt_Example
//
//  Created by david on 5/16/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

import SushiBelt

fileprivate final class MatrixCell: UICollectionViewCell {

  static let identifier = "MatrixCell"

  private let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(self.imageView)
    self.contentView.backgroundColor = UIColor(red: 1.0, green: 0.83, blue: 0.47, alpha: 1.0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageView.image = nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.imageView.frame.size = CGSize(width: 200.0, height: 200.0)
    self.imageView.center = self.contentView.center
    self.contentView.layer.cornerRadius = 24.0
  }

  func configure(sushi: Sushi) {
    self.imageView.image = sushi.image
  }
}

class MatrixViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  var collectionView: UICollectionView!
  private let tracker = SushiBeltTracker()
  private let debugger = SushiBeltDebugger.shared
  private let sections: [[Sushi]] = [
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10),
    Sushi.いらっしゃいませ(count: 10)
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
      let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(300))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
      let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300 * 10), heightDimension: .absolute(300))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 10)
      let section = NSCollectionLayoutSection(group: group)
      return section
    }

    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.backgroundColor = .white
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(MatrixCell.self, forCellWithReuseIdentifier: MatrixCell.identifier)
    view.addSubview(collectionView)
    self.tracker.delegate = self
    self.tracker.dataSource = self
    self.tracker.registerDebugger(debugger: self.debugger)
    self.debugger.show()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    trackingVisibleCellsIfNeeded()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    tracker.calculateItemsIfNeeded(items: [])
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sections.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sections[section].count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatrixCell.identifier, for: indexPath) as? MatrixCell else {
      return .init()
    }

    let section = sections[indexPath.section]
    let item = section[indexPath.item]
    cell.configure(sushi: item)
    return cell
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    trackingVisibleCellsIfNeeded()
  }

  private func trackingVisibleCellsIfNeeded() {
    let trackingItems = self.collectionView.visibleCells.compactMap { cell -> SushiBeltTrackerItem? in
      guard let indexPath = self.collectionView.indexPath(for: cell) else { return nil }

      return SushiBeltTrackerItem(
        id: .indexPath(indexPath),
        rect: cell.sushiBeltTrackerItemRect()
      )
    }
    self.tracker.calculateItemsIfNeeded(items: trackingItems)
  }
}

extension MatrixViewController: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    collectionView.frame
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard case let .indexPath(indexPath) = item.id else { return 0.0 }
    return sections[indexPath.section][indexPath.item].kind.visibleRatio
  }
}

extension MatrixViewController: SushiBeltTrackerDelegate {

  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {

    print("🚀 begin tracking: \(item.debugDescription)")
  }

  func didTrack(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {

    print("🎯 tracked: \(item.debugDescription)")
  }

  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {

    print("👋 end tracking: \(item.debugDescription)")
  }
}
