//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

// MARK: - View Extensions

extension View {

  /// 이 뷰의 하위에서 `.impressionTrackable()`을 사용하는 아이템들의 임프레션을 추적하는 컨테이너를 설정합니다.
  ///
  /// 컨테이너는 가시 영역(`containerFrame`)과 활성 상태(`isActive`)를 관리하며,
  /// 뷰 라이프사이클(`viewDidAppear` / `onDisappear`)과 앱 라이프사이클에 자동 대응합니다.
  ///
  /// ```swift
  /// List {
  ///   ForEach(items, id: \.self) { item in
  ///     Text(item)
  ///       .impressionTrackable(id: item) {
  ///         print("임프레션: \(item)")
  ///       }
  ///   }
  /// }
  /// .impressionTrackableContainer()
  /// .impressionPolicy(.cooldown(interval: 30))
  /// ```
  ///
  /// - Parameter visibleArea: 임프레션 판정 기준이 되는 가시 영역 범위. 기본값은 `.ignoringSafeArea()`.
  public func impressionTrackableContainer(
    visibleArea: VisibleAreaRegion = .ignoringSafeArea()
  ) -> some View {
    modifier(
      ImpressionTrackingContainerModifier(visibleArea: visibleArea)
    )
  }

  /// 임프레션 허용 여부를 결정하는 정책을 주입합니다.
  ///
  /// `policy.id`가 동일하면 기존 인스턴스(내부 상태 포함)가 보존되고,
  /// `id`가 변경되면 새 인스턴스로 교체됩니다.
  ///
  /// - Parameter policy: 임프레션 정책
  public func impressionPolicy(_ policy: some ImpressionPolicy) -> some View {
    modifier(ImpressionPolicyModifier(policy: policy))
  }

  /// 이 뷰를 `.impressionTrackableContainer()` 컨테이너 안에서 임프레션 추적 대상으로 등록합니다.
  ///
  /// 뷰의 가시 비율이 `visibilityThreshold` 이상이 되면 임프레션이 발생합니다.
  /// 동일 아이템이 화면을 벗어났다가 다시 들어오면 새로운 임프레션이 발생할 수 있습니다.
  ///
  /// `tracksExit`가 `true`이면 진입/이탈을 대칭으로 추적하여, 임계값을 넘어설 때 `onImpressionEnter`를,
  /// 다시 내려가거나 가시 집합에서 사라질 때 `onImpressionExit`를 발화합니다. 컨테이너 비활성화
  /// (백그라운드 전환·뷰 이탈) 시 아직 이탈하지 않은 항목의 이탈은 best-effort로 발화됩니다.
  ///
  /// - Parameters:
  ///   - id: 추적 대상의 고유 식별자
  ///   - visibilityThreshold: 임프레션 판정에 필요한 최소 가시 비율 (0.0 ~ 1.0). 기본값은 `0.0`.
  ///   - tracksExit: 이탈(`onImpressionExit`) 추적 여부. 기본값은 `false`.
  ///   - onImpressionEnter: 진입(임프레션)이 발생했을 때 호출되는 콜백
  ///   - onImpressionExit: `tracksExit`가 `true`일 때 이탈 시점에 호출되는 콜백
  public func impressionTrackable(
    id: some Hashable,
    visibilityThreshold: CGFloat = 0.0,
    tracksExit: Bool = false,
    onImpressionEnter: @escaping () -> Void,
    onImpressionExit: (() -> Void)? = nil,
  ) -> some View {
    modifier(
      ImpressionTrackableModifier(
        item: ImpressionItem(
          id: id,
          visibilityThreshold: visibilityThreshold,
          tracksExit: tracksExit,
        ),
        onImpressionEnter: onImpressionEnter,
        onImpressionExit: onImpressionExit,
      )
    )
  }

  /// 이 뷰를 미리 구성된 `ImpressionItem`으로 임프레션 추적 대상으로 등록합니다.
  ///
  /// `item.tracksExit`가 `true`이면 이탈 시점에 `onImpressionExit`가 발화됩니다.
  ///
  /// - Parameters:
  ///   - item: 추적 대상 아이템 (`id`·`visibilityThreshold`·`tracksExit`를 포함)
  ///   - onImpressionEnter: 진입(임프레션)이 발생했을 때 호출되는 콜백
  ///   - onImpressionExit: `item.tracksExit`가 `true`일 때 이탈 시점에 호출되는 콜백
  public func impressionTrackable(
    item: ImpressionItem,
    onImpressionEnter: @escaping () -> Void,
    onImpressionExit: (() -> Void)? = nil,
  ) -> some View {
    modifier(
      ImpressionTrackableModifier(
        item: item,
        onImpressionEnter: onImpressionEnter,
        onImpressionExit: onImpressionExit,
      )
    )
  }
}

