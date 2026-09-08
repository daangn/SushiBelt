//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// 임프레션 추적 대상 아이템을 정의하는 구조체.
///
/// 식별자(`id`)와 가시 비율 임계값(`visibilityThreshold`)을 묶어서 관리합니다.
/// `impressionTrackable(item:onImpressionEnter:onImpressionExit:)`에서 사용됩니다.
public struct ImpressionItem: Hashable {

  /// 추적 대상 아이템의 고유 식별자
  public let id: AnyHashable

  /// 임프레션으로 판정하기 위한 최소 가시 비율 (0.0 ~ 1.0)
  ///
  /// 예를 들어 `0.5`이면 아이템 면적의 50% 이상이 화면에 보여야 임프레션으로 판정됩니다.
  /// `0.0`이면 1px이라도 보이는 즉시 임프레션이 발생합니다.
  public let visibilityThreshold: CGFloat

  /// 임계값 아래로 다시 내려갈 때 이탈(`onImpressionExit`)을 발화할지 여부.
  ///
  /// `false`(기본)이면 단발성으로 동작하여 진입 시 `onImpressionEnter`가 한 번 발화되고
  /// 이탈은 추적하지 않습니다. `true`이면 진입/이탈을 대칭으로 추적하여, 임계값을
  /// 넘어설 때 진입을, 다시 내려가거나 가시 집합에서 사라질 때 이탈을 발화합니다.
  public let tracksExit: Bool

  public init(
    id: some Hashable,
    visibilityThreshold: CGFloat,
    tracksExit: Bool = false,
  ) {
    self.id = AnyHashable(id)
    self.visibilityThreshold = min(max(visibilityThreshold, 0.0), 1.0)
    self.tracksExit = tracksExit
  }
}

