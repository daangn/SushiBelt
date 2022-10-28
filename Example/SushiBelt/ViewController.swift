//
//  ViewController.swift
//  SushiBelt
//
//  Created by david on 03/07/2022.
//  Copyright (c) 2022 david. All rights reserved.
//

import UIKit
import SushiBelt

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

final class TestCell: UICollectionViewCell {
  
  static let identifier = "TestCell"
  
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

class ViewController: UIViewController {
  
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 0.0
    layout.minimumInteritemSpacing = 0.0
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .white
    view.register(TestCell.self, forCellWithReuseIdentifier: TestCell.identifier)
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

extension ViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.sushis.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCell.identifier, for: indexPath) as? TestCell else {
      fatalError()
    }
    let sushi = self.sushis[indexPath.item]
    cell.configure(sushi: sushi)
    return cell
  }
  
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
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


extension ViewController: SushiBeltTrackerDataSource {
  
  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.collectionView.frame
  }
  
  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard case let .indexPath(indexPath) = item.id else { return 0.0 }
    return self.sushis[indexPath.item].kind.visibleRatio
  }
}

extension ViewController: SushiBeltTrackerDelegate {
  
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
