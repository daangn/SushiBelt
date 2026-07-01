//
//  SymmetricListViewController.swift
//  SushiBelt_Example
//
//  Demonstrates symmetric threshold tracking via the `tracksExit` opt-in.
//  Each item registers with `tracksExit: true`, so the tracker fires
//  `didExit(_:item:)` when the item drops below the threshold while
//  staying in the visible set, and re-fires `didEnter(_:item:)` when it
//  crosses back up.
//
//  Scroll the list and watch the console for:
//    🎯 enter       — ratio crossed ≥ threshold (start of a visible session)
//    🚪 exit        — ratio dropped < threshold or item left the set
//                     (end of the visible session, paired with the prior 🎯)
//    🚀 begin / 👋 end  — existing set lifecycle callbacks
//

import UIKit

import SushiBelt

final class SymmetricListTestCell: UICollectionViewCell {

  static let identifier = "SymmetricListTestCell"

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

class SymmetricListViewController: UIViewController {

  /// Fixed threshold for this demo so the symmetric crossing point is easy
  /// to reason about while scrolling.
  private static let visibleThreshold: CGFloat = 0.5

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 0.0
    layout.minimumInteritemSpacing = 0.0
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .white
    view.register(SymmetricListTestCell.self, forCellWithReuseIdentifier: SymmetricListTestCell.identifier)
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
    self.title = "Symmetric"
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

extension SymmetricListViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.sushis.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SymmetricListTestCell.identifier, for: indexPath) as? SymmetricListTestCell else {
      fatalError()
    }
    let sushi = self.sushis[indexPath.item]
    cell.configure(sushi: sushi)
    return cell
  }

}

extension SymmetricListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
        rect: cell.sushiBeltTrackerItemRect(),
        tracksExit: true
      )
    }
    self.tracker.calculateItemsIfNeeded(items: trackingItems)
  }

}

extension SymmetricListViewController: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.collectionView.frame
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    return SymmetricListViewController.visibleThreshold
  }
}

extension SymmetricListViewController: SushiBeltTrackerDelegate {

  func willBeginTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    print("🚀 begin tracking: \(item.debugDescription)")
  }

  func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    print("🎯 enter: \(item.debugDescription)")
  }

  func didExit(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    print("🚪 exit: \(item.debugDescription)")
  }

  func didEndTracking(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    print("👋 end tracking: \(item.debugDescription)")
  }
}
