//
//  ViewController.swift
//  SushiBelt
//
//  Created by david on 03/07/2022.
//  Copyright (c) 2022 david. All rights reserved.
//

import UIKit
import SushiBelt

final class TestCell: UICollectionViewCell {
  
  static let identifier = "TestCell"
  
  private let label = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(self.label)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.label.text = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.label.sizeToFit()
    self.label.center = self.contentView.center
  }
  
  func configure(indexPath: IndexPath) {
    self.label.text = "\(indexPath.item)"
    self.label.font = UIFont.boldSystemFont(ofSize: 36.0)
    self.label.textColor = UIColor.white
    if indexPath.item % 2 == 0 {
      self.backgroundColor = UIColor.gray
    } else {
      self.backgroundColor = UIColor.darkGray
    }
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
  
  override func loadView() {
    self.view = self.collectionView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tracker.delegate = self
    self.tracker.dataSource = self
    self.tracker.scrollView = self.collectionView
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
    return 100
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCell.identifier, for: indexPath) as? TestCell else {
      fatalError()
    }
    cell.configure(indexPath: indexPath)
    return cell
  }
  
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 300.0)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.trackingVisibleCellsIfNeeded()
  }
  
  private func trackingVisibleCellsIfNeeded() {
    let trackingItems = self.collectionView.visibleCells.compactMap { cell -> SushiBeltTrackerItem? in
      guard let indexPath = self.collectionView.indexPath(for: cell) else { return nil }
      return SushiBeltTrackerItem(
        id: .indexPath(indexPath),
        view: cell
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
    return 0.5
  }
}

extension ViewController: SushiBeltTrackerDelegate {
  
  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    
    print("🚀 begin tracking: \(item.debugDescription)")
  }
  
  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    
    print("👋 end tracking: \(item.debugDescription)")
  }
}
