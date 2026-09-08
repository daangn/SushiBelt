//
//  ImpressionEventTrackable.swift
//  KarrotImpressionInterface
//
//  Created by Ben on 2023/06/02.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// VisibleStateDetectorItem를 필터링하는 클로저
public typealias ImpressionItemFilter = (VisibleStateDetectorItem) -> Bool

/// ImpressionEvent가 발생하여 콜백된 VisibleStateDetectorItem을 처리하는 클로저
public typealias ImpressionEventCallback = (VisibleStateDetectorItem) -> Void

/// @mockable
/// 주어진 `UIScrollView`의 SubViews의 Visible 상태 이벤트를 추적하고 감지하는 타입
public protocol ImpressionEventTrackable {

  /// `UIScrollView`의 Visible Subviews의 Impression Event를 구독 받기 위해 등록해요.
  ///
  /// - Parameters:
  ///   - viewController: `UIScrollView`를 소유하고 있는 `UIViewController` 타입
  ///   - scrollView: Subviews의 Impression Event를 추적할 `UIScrollView`
  ///   - detectorItemFactory: 추적할 아이템을 만들기 위한 Factory
  ///   - trackingRect: 추적하려는 범위
  ///
  /// - Note: `UIScrollView`를 포함하고 있는 최상위 `UIViewController`에서 등록시 사용해요.
  /// `UIApplication`, `UIViewController`의 생명주기에 따라 Scene이 다시 노출될때 Impression Event를 갱신해요.
  func register(
    viewController: UIViewController,
    scrollView: UIScrollView,
    detectorItemFactory: DetectorItemFactory,
    trackingRect: @escaping (() -> CGRect),
  )

  /// `UIScrollView`의 Visible Subviews의 Impression Event를 구독 받기 위해 등록해요.
  ///
  /// - Parameters:
  ///   - scrollView: Subviews의 Impression Event를 추적할 `UIScrollView`
  ///   - detectorItemFactory: 추적할 아이템을 만들기 위한 Factory
  ///   - trackingRect: 추적하려는 범위
  ///
  /// - Note: `UIScrollView`를 포함하고 있는 Cell (`UITableViewCell`, `UICollectionViewCell`)에서 등록시 사용해요.
  /// Cell이 `ImpressionInnerScrollable` protocol을 conform하면 상위로 부터 보여지거나 사라졌을때 콜밷 받을 수 있어요.
  func register(
    scrollView: UIScrollView,
    detectorItemFactory: DetectorItemFactory,
    trackingRect: @escaping (() -> CGRect),
  )

  /// `ImpressionItem`을 필터링하기 위한 필터 클로저를 설정해요.
  ///
  /// - Parameter filter: `ImpressionItem`을 필터링하는 클로저 (클로저가 `false`를 반환하면 해당 아이템은 무시)
  func setFilter(_ filter: @escaping ImpressionItemFilter)

  /// `ImpressionEventCallback`을 구현하여 `ImpressionEvent`를 구독해요.
  ///
  /// - Parameter callback: `ImpressionEvent`를 처리하는 클로저
  func subscribe(callback: @escaping ImpressionEventCallback)

  /// 수동으로 등록된 `UIScroll` 서브뷰들의 Impression 상태 탐지를 요청해요.
  ///
  /// - Note: `UITableView`, `UICollectionView` reloadData() 호출 직후에 Visible 상태의 Item을 콜백받을 수 없어요.
  /// 이러한 경우 `reloadData()` completion handler 등 위치에서 수동으로 탐지를 하기 위해 사용해요.
  /// - Parameter shouldResetCache: 현재 추적중인 DetectorItem들을 제거 여부 값
  func trackManually(shouldResetCache: Bool)

  /// 노출 중인 아이템을 저장하고 있는 캐시를 모두 제거해요.
  ///
  /// 리스트에서 Pull To Refresh 등 전체 갱신하는 경우, 기존의 캐시를 제거해야 갱신 이후 동일한 아이템에 대해 노출 콜백을 받을 수 있어요.
  func clearCache()

  /// 디버깅 모드를 활성화 해요.
  func enableDebugging()
}

