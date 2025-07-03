//
//  SingleListViewController.swift
//  SushiBelt_Example
//
//  Created by david on 2022/11/06.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

import SushiBelt

final class SingleListTestCell: UICollectionViewCell {

  static let identifier = "SingleListTestCell"

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

class SingleListViewController: UIViewController {

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 0.0
    layout.minimumInteritemSpacing = 0.0
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .white
    view.register(SingleListTestCell.self, forCellWithReuseIdentifier: SingleListTestCell.identifier)
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
    self.title = "Single List"
    self.view.backgroundColor = UIColor.systemBackground
    self.tracker.delegate = self
    self.tracker.dataSource = self
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

extension SingleListViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.sushis.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleListTestCell.identifier, for: indexPath) as? SingleListTestCell else {
      fatalError()
    }
    let sushi = self.sushis[indexPath.item]
    cell.configure(sushi: sushi)
    return cell
  }

}

extension SingleListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 300.0)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 24.0
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

extension SingleListViewController: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.collectionView.frame
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard case let .indexPath(indexPath) = item.id else { return 0.0 }
    return self.sushis[indexPath.item].kind.visibleRatio
  }
}

extension SingleListViewController: SushiBeltTrackerDelegate {

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
