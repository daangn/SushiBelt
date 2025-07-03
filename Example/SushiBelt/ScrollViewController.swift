//
//  ScrollViewController.swift
//  SushiBelt_Example
//
//  Created by david on 2022/11/06.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

import SushiBelt

final class SrollChildView: UIView {

  private let imageView = UIImageView()

  func configure(sushi: Sushi) {
    self.imageView.image = sushi.image
  }

  let visibleRatio: CGFloat

  init(sushi: Sushi) {
    self.visibleRatio = sushi.kind.visibleRatio
    super.init(frame: .zero)
    self.imageView.image = sushi.image
    self.addSubview(self.imageView)
    self.backgroundColor = UIColor(red: 1.0, green: 0.83, blue: 0.47, alpha: 1.0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.imageView.frame.size = CGSize(width: 200.0, height: 200.0)
    self.imageView.frame.origin = .init(
      x: (self.bounds.width - 200.0) * 0.5,
      y: (self.bounds.height - 200.0) * 0.5
    )
    self.layer.cornerRadius = 24.0
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(
      width: size.width * 0.8,
      height: size.height * 0.5
    )
  }
}

final class ScrollViewController: UIViewController {

  private var childViews: [SrollChildView] = []
  private let scrollView = UIScrollView()

  private let tracker = SushiBeltTracker()
  private let debugger = SushiBeltDebugger.shared

  override func loadView() {
    self.view = scrollView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "ScrollView"
    self.view.backgroundColor = UIColor.systemBackground

    self.tracker.delegate = self
    self.tracker.dataSource = self
    self.tracker.registerDebugger(debugger: self.debugger)
    self.debugger.show()

    self.scrollView.delegate = self
    self.childViews = Sushi.いらっしゃいませ(count: 10).map {
      SrollChildView(sushi: $0)
    }
    self.childViews.forEach {
      self.scrollView.addSubview($0)
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    var offsetY: CGFloat = 16.0

    self.childViews.forEach { childView in
      childView.frame.size = childView.sizeThatFits(self.view.frame.size)
      childView.frame.origin = .init(
        x: (self.view.frame.width - childView.frame.width) * 0.5,
        y: offsetY
      )
      offsetY += childView.frame.size.height + 16.0
    }

    self.scrollView.contentSize = .init(
      width: self.view.frame.width,
      height: (self.childViews.last?.frame.origin.y ?? 0.0) + (self.childViews.last?.frame.size.height ?? 0.0) + 16.0
    )
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.trackIfNeeded()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.tracker.calculateItemsIfNeeded(items: [])
  }

  private func trackIfNeeded() {
    self.tracker.calculateItemsIfNeeded(
      items: self.childViews.enumerated().map { index, childView -> SushiBeltTrackerItem in
        SushiBeltTrackerItem(
          id: .index(index),
          rect: childView.sushiBeltTrackerItemRect()
        )
      }
    )
  }
  
}

extension ScrollViewController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.trackIfNeeded()
  }
}

extension ScrollViewController: SushiBeltTrackerDataSource {

  func trackingRect(_ tracker: SushiBeltTracker) -> CGRect {
    return self.scrollView.frame
  }

  func visibleRatioForItem(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) -> CGFloat {
    guard case let .index(index) = item.id else { return 0.0 }
    return self.childViews[index].visibleRatio
  }
}

extension ScrollViewController: SushiBeltTrackerDelegate {

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
