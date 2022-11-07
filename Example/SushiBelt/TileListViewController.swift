//
//  TileListViewController.swift
//  SushiBelt_Example
//
//  Created by david on 2022/11/06.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SushiBelt

final class TileListTestCell: UICollectionViewCell {

  static let identifier = "TileListTestCell"

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
    self.imageView.frame.size = CGSize(width: 50.0, height: 50.0)
    self.imageView.center = self.contentView.center
    self.contentView.layer.cornerRadius = 24.0
  }

  func configure(sushi: Sushi) {
    self.imageView.image = sushi.image
  }
}

class TileListViewController: UIViewController {

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 20.0
    layout.minimumInteritemSpacing = 20.0
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .white
    view.register(TileListTestCell.self, forCellWithReuseIdentifier: TileListTestCell.identifier)
    return view
  }()

  private let tracker = SushiBeltTracker()
  private let debugger = SushiBeltDebugger.shared

  private let sushis = Sushi.いらっしゃいませ(count: 200)

  override func loadView() {
    self.view = self.collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Tile List"
    self.view.backgroundColor = UIColor.systemBackground
    self.tracker.delegate = self
    self.tracker.dataSource = self
    self.tracker.scrollContext = SushiBeltTrackerUIScrollContext(scrollView: self.collectionView)
    self.tracker.registerDebugger(debugger: self.debugger)
    self.debugger.show()
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.trackingVisibleCellsIfNeeded()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.tracker.calculateItemsIfNeeded(items: [])
  }
}

extension TileListViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.sushis.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TileListTestCell.identifier, for: indexPath) as? TileListTestCell else {
      fatalError()
    }
    let sushi = self.sushis[indexPath.item]
    cell.configure(sushi: sushi)
    return cell
  }

}

extension TileListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: floor(collectionView.bounds.width / 3.0 - 40.0),
      height: floor(collectionView.bounds.width / 3.0 - 40.0)
    )
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.trackingVisibleCellsIfNeeded()
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

extension TileListViewController: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.collectionView.frame
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard case let .indexPath(indexPath) = item.id else { return 0.0 }
    return self.sushis[indexPath.item].kind.visibleRatio
  }
}

extension TileListViewController: SushiBeltTrackerDelegate {

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
