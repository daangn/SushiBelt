//
//  ImpressionEventTracker.swift
//  KarrotImpression
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Combine
import UIKit

import RxCocoa
import RxSwift

final class ImpressionEventTracker: ImpressionEventTrackable {

  private let detector: VisibleStateDetectable
  private let application: UIApplication.Type
  private let cooltimeCache: ImpressionCooltimeCache
  private var trackingRectangle: (() -> CGRect)?
  private var detectorItemFactory: DetectorItemFactory?
  private var filter: ImpressionItemFilter?
  private var callback: ImpressionEventCallback?

  private var scrollView: UIScrollView?

  /// Gates manual tracking while the registered view controller is offscreen.
  ///
  /// Set to `true` on `viewWillAppear` and `false` on `viewDidDisappear`.
  /// Items are reevaluated on `viewDidAppear`; suppressed manual checks are not queued.
  /// Without a registered view controller, this remains `true`.
  private var isViewControllerVisible = true
  private var sourceIdentifier: String?

  #if DEBUG
  /// Pairs overlay reports with cleanup for this tracker.
  /// A UUID avoids clearing another tracker's rect if a deallocated object's address is reused.
  private let debugOverlayKey: UUID = .init()
  #endif

  private var cancellables: Set<AnyCancellable> = []
  private let disposeBag: DisposeBag = .init()

  init(
    detector: VisibleStateDetectable,
    application: UIApplication.Type,
    cooltimeCache: ImpressionCooltimeCache,
  ) {
    self.detector = detector
    self.application = application
    self.cooltimeCache = cooltimeCache
    detector.delegate = self
  }

  #if DEBUG
  deinit {
    // A tracker can be released without a preceding viewDidDisappear callback.
    ImpressionDebugOverlay.shared.clearTrackingRect(key: debugOverlayKey)
  }
  #endif

  func register(
    viewController: UIViewController,
    scrollView: UIScrollView,
    detectorItemFactory: DetectorItemFactory,
    trackingRect: @escaping (() -> CGRect),
  ) {
    sourceIdentifier = String(describing: type(of: viewController))
    self.scrollView = scrollView
    self.detectorItemFactory = detectorItemFactory
    trackingRectangle = trackingRect
    observeApplicationLifeCycleEvent(viewController: viewController)
    observeViewControllerLifeCycleEvent(viewController: viewController)
    observeScrollViewEvent(scrollView: scrollView)
  }

  func register(
    scrollView: UIScrollView,
    detectorItemFactory: DetectorItemFactory,
    trackingRect: @escaping (() -> CGRect),
  ) {
    self.scrollView = scrollView
    self.detectorItemFactory = detectorItemFactory
    trackingRectangle = trackingRect
    observeScrollViewEvent(scrollView: scrollView)
  }

  func setFilter(_ filter: @escaping ImpressionItemFilter) {
    self.filter = filter
  }

  func subscribe(callback: @escaping ImpressionEventCallback) {
    self.callback = callback
  }

  func trackManually(shouldResetCache: Bool) {
    guard isViewControllerVisible else {
      return
    }
    if shouldResetCache {
      clearCache()
    }
    detectVisibleItemsIfNeeded(source: "manual")
  }

  func clearCache() {
    guard callback != nil else { return }
    detector.clear()
  }

  func enableDebugging() {
    detector.showDebugger()
  }

  private func observeApplicationLifeCycleEvent(viewController: UIViewController) {
    application.rx.didBecomeActive
      .withLatestFrom(viewController.rx.isVisible)
      .filter { $0 }
      .bind(onNext: { [weak self] _ in
        self?.detectVisibleItemsIfNeeded(source: "didBecomeActive")
      })
      .disposed(by: disposeBag)

    application.rx.willResignActive
      .withLatestFrom(viewController.rx.isVisible)
      .filter { $0 }
      .bind(onNext: { [weak self] _ in
        self?.clearCache()
      })
      .disposed(by: disposeBag)
  }

  private func observeViewControllerLifeCycleEvent(viewController: UIViewController) {
    viewController.rx.viewWillAppear
      .bind(onNext: { [weak self] _ in
        self?.isViewControllerVisible = true
      })
      .disposed(by: disposeBag)

    viewController.rx.viewDidAppear
      .bind(onNext: { [weak self] _ in
        self?.detectVisibleItemsIfNeeded(source: "viewDidAppear")
      })
      .disposed(by: disposeBag)

    viewController.rx.viewDidDisappear
      .bind(onNext: { [weak self] _ in
        self?.isViewControllerVisible = false
        self?.clearCache()
        #if DEBUG
        if let self {
          ImpressionDebugOverlay.shared.clearTrackingRect(key: debugOverlayKey)
        }
        #endif
      })
      .disposed(by: disposeBag)
  }

  private func observeScrollViewEvent(scrollView: UIScrollView) {
    scrollView.publisher(for: \.contentOffset)
      .didChange()
      .filter(isValidScrolling())
      .sink { [weak self] _ in
        self?.detectVisibleItemsIfNeeded(source: "scroll")
      }
      .store(in: &cancellables)
  }

  private func detectVisibleItemsIfNeeded(source: String) {
    guard let scrollView, let detectorItemFactory, let trackingRectangle, callback != nil else {
      return
    }

    #if DEBUG
    reportTrackingRectToDebugOverlayIfNeeded()
    #endif

    let items = detectorItemFactory.makeVisibleDetectorItems(view: scrollView)

    detector.detect(
      items: items,
      trackingRect: trackingRectangle,
    )
  }

  #if DEBUG
  /// Reports the tracking area using the same provider passed to the detector.
  ///
  /// Overlay state and UIKit geometry are read on the main thread. Recheck
  /// visibility after dispatching so a delayed report cannot restore a cleared rect.
  /// Skip geometry evaluation when the overlay is disabled.
  private func reportTrackingRectToDebugOverlayIfNeeded() {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?.reportTrackingRectToDebugOverlayIfNeeded()
      }
      return
    }
    guard
      ImpressionDebugOverlay.shared.showsTrackingRect,
      isViewControllerVisible,
      let scrollView,
      let trackingRectangle
    else { return }

    ImpressionDebugOverlay.shared.reportTrackingRect(
      trackingRectangle(),
      key: debugOverlayKey,
      scrollView: scrollView,
      sourceIdentifier: sourceIdentifier,
    )
  }
  #endif

  private func isValidScrolling() -> (() -> Bool) {
    { [weak self] in
      guard let scrollView = self?.scrollView else { return false }
      return scrollView.isTracking
        || scrollView.isDecelerating
        || scrollView.isDragging
    }
  }
}

extension ImpressionEventTracker: VisibleStateDetectorDelegate {

  func onDetect(visibleItem: VisibleStateDetectorItem) {
    if let filter, filter(visibleItem) == false {
      return
    }
    guard passesCooltime(visibleItem) else {
      return
    }
    callback?(visibleItem)
  }

  /// Checks whether the item's cooldown permits an impression.
  ///
  /// A `nil` ``VisibleStateDetectorItem/cooltime`` bypasses the cooldown check.
  ///
  /// This check can record an expiration, so call it only after the item passes the filter.
  private func passesCooltime(_ item: VisibleStateDetectorItem) -> Bool {
    guard let cooltime = item.cooltime else {
      return true
    }
    return !cooltimeCache.isInCooltime(
      for: cooltime.key,
      coolingTime: cooltime.coolingTime,
    )
  }
}
