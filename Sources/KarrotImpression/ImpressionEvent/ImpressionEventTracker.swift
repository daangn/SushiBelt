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

  /// 트래커에 등록된 뷰컨트롤러가 화면에 보이고 있는지 여부.
  ///
  /// `viewWillAppear()`에서 `true`로 `viewDidDisappear()`에서 `false`로 설정합니다.\
  /// `trackManually` 함수가 화면이 보이지 않는 경우에 호출될 경우 (ex. 자동 refresh),
  /// Impression 이벤트가 콜백되지 않도록 분기하는 용도로 사용됩니다.\
  /// `false`로 전송되지 않은 이벤트는 `viewDidAppear` 시점에 콜백 받을 수 있습니다.
  ///
  /// - NOTE: `register`시 `viewController`를 주입하지 않는 경우 해당 변수는 true로 사용됩니다.\
  /// 이는, 사이드이펙트를 발생할 수 있기에, 별도의 구조 리팩토링이 필요합니다.
  private var isViewControllerVisible = true
  private var sourceIdentifier: String?

  #if DEBUG
  /// 디버깅 오버레이의 rect 보고와 제거를 짝지어 주는 트래커 고유 key예요.
  /// `ObjectIdentifier`는 트래커 해제 후 같은 주소가 재사용되면 다른 트래커의 rect를 지울 수 있어서 쓰지 않아요.
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
    // 화면 재구성 등으로 `viewDidDisappear` 없이 트래커만 해제될 때도 오버레이에 rect가 남지 않게 해요.
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
  /// 디버깅 오버레이가 노출 판정에 실제로 사용하는 rect 원본을 그리도록,
  /// `detector.detect(items:trackingRect:)`에 넘기는 것과 같은 `trackingRectangle` 값을 보고해요.
  ///
  /// `trackManually`처럼 판정이 백그라운드에서 트리거될 수 있어서, main 전용인 오버레이 표시 여부 읽기와
  /// `trackingRectangle()`의 UIKit 지오메트리 평가가 모두 main에서 일어나도록 먼저 main으로 수렴해요.
  /// main 도착 시점에 화면이 이미 사라졌다면 건너뛰어, `viewDidDisappear`에서 지운 rect가
  /// 늦게 도착한 보고로 되살아나지 않게 해요. 오버레이가 꺼져 있으면 클로저 평가 비용 없이 반환해요.
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

  /// 아이템의 쿨타임 정보로 발화 가능 여부를 판정해요.
  ///
  /// 아이템의 ``VisibleStateDetectorItem/cooltime``이 `nil`이면 쿨타임을 적용하지 않아요.
  ///
  /// 판정 과정에서 쿨타임 캐시에 만료 시각이 기록되므로, 필터를 통과해 실제로 발화할 아이템에만 호출해요.
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

