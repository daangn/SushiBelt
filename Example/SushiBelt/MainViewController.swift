//
//  MainViewController.swift
//  SushiBelt_Example
//
//  Created by david on 2022/11/06.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

import SushiBelt

final class MainTestCell: UICollectionViewCell {

  static let identifier = "MainTestCell"

  private let imageView = UIImageView()
  private let titleLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(self.imageView)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.backgroundColor = UIColor(red: 1.0, green: 0.83, blue: 0.47, alpha: 1.0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageView.image = nil
    self.titleLabel.text = nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.imageView.frame.size = CGSize(width: 200.0, height: 200.0)
    self.imageView.center = self.contentView.center
    self.titleLabel.sizeToFit()
    self.titleLabel.frame = .init(
      x: (self.frame.width - self.titleLabel.frame.size.width) * 0.5,
      y: self.imageView.frame.origin.y + self.imageView.frame.size.height + 20.0,
      width: self.titleLabel.frame.size.width,
      height: self.titleLabel.frame.size.height
    )
    self.contentView.layer.cornerRadius = 24.0
  }

  func configure(kind: MainTestKind) {
    self.imageView.image = kind.image
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    self.titleLabel.attributedText = NSAttributedString(
      string: kind.title,
      attributes: [
        NSAttributedStringKey.foregroundColor: UIColor.darkGray,
        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24.0, weight: .bold),
        NSAttributedStringKey.paragraphStyle: paragraphStyle
      ]
    )
  }
}

final class MainViewController: UIViewController {

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 24.0
    layout.minimumInteritemSpacing = 24.0
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .white
    view.register(MainTestCell.self, forCellWithReuseIdentifier: MainTestCell.identifier)
    view.contentInset = .init(top: 0.0, left: 24.0, bottom: 0.0, right: 24.0)
    return view
  }()

  private let tracker = SushiBeltTracker()
  private let debugger = SushiBeltDebugger.shared

  private let kinds = MainTestKind.allCases

  override func loadView() {
    self.view = self.collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Welcome to ShushiBelt"
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
  
}

extension MainViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.kinds.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainTestCell.identifier, for: indexPath) as? MainTestCell else {
      fatalError()
    }
    let kind = self.kinds[indexPath.item]
    cell.configure(kind: kind)
    return cell
  }

}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch self.kinds[indexPath.item] {
    case .single:
      self.navigationController?.pushViewController(
        SingleListViewController(),
        animated: true
      )

    case .scroll:
      self.navigationController?.pushViewController(
        ScrollViewController(),
        animated: true
      )
      
    case .tile:
      self.navigationController?.pushViewController(
        TileListViewController(),
        animated: true
      )

    case .matrix:
      self.navigationController?.pushViewController(
        MatrixViewController(),
        animated: true
      )
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: 300.0,
      height: collectionView.frame.height * 0.5
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


extension MainViewController: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.collectionView.frame
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard case let .indexPath(indexPath) = item.id else { return 0.0 }
    return self.kinds[indexPath.item].visibleRatio
  }
}

extension MainViewController: SushiBeltTrackerDelegate {

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
