//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

/// 임프레션 판정 시 기준이 되는 가시 영역의 범위를 결정합니다.
///
/// 컨테이너의 `visibleArea` 파라미터로 전달하여, 어디까지를 "화면에 보이는 영역"으로
/// 취급할지 제어합니다. Safe area를 포함할지 여부에 따라 임프레션 판정 결과가 달라집니다.
///
/// ```swift
/// // 모든 safe area를 무시하여 가시 영역을 확장 (기본값)
/// .impressionTrackableContainer(visibleArea: .ignoringSafeArea())
///
/// // safe area 안쪽만 가시 영역으로 사용
/// .impressionTrackableContainer(visibleArea: .safeArea)
///
/// // 특정 방향의 safe area만 무시
/// .impressionTrackableContainer(visibleArea: .ignoringSafeArea(edges: .bottom))
/// ```
public enum VisibleAreaRegion {

  /// 세이프 에리어 안쪽만 가시 영역으로 사용합니다.
  case safeArea

  /// 특정 safe area를 무시하여 가시 영역을 확장합니다.
  ///
  /// SwiftUI의 `ignoresSafeArea(_:edges:)`와 동일한 개념입니다.
  /// 기본값은 모든 영역(`.all`)과 모든 방향(`.all`)의 safe area를 무시합니다.
  case ignoringSafeArea(regions: SafeAreaRegions = .all, edges: Edge.Set = .all)

  /// `ignoresSafeArea`에 전달할 세이프 에리어 영역
  public var safeAreaRegions: SafeAreaRegions {
    switch self {
    case .safeArea: .all
    case .ignoringSafeArea(let regions, _): regions
    }
  }

  /// `ignoresSafeArea`에 전달할 방향
  public var safeAreaEdges: Edge.Set {
    switch self {
    case .safeArea: []
    case .ignoringSafeArea(_, let edges): edges
    }
  }
}

