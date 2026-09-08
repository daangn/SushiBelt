//
//  Created by jamie hyeon on 6/23/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// SwiftUI에 의존하지 않는 임프레션 발화 결정 UseCase.
///
/// "직전 가시 집합 + 현재 가시 집합 + 진입한 롱임프레션 집합 + 정책 판정"으로부터
/// 이번에 발화할 진입/이탈 엔트리와 다음 비교용 상태를 순수하게 계산합니다.
/// `onImpressionEnter()`·`onImpressionExit()` 호출이나 상태 저장 같은 부수효과는 호출 측이 담당합니다.
struct ImpressionFiringDecideUseCase {

  /// 발화 결정 결과.
  struct Decision {

    /// 이번에 `onImpressionEnter()`를 호출해야 하는 엔트리.
    let entriesToFire: [ImpressionEntry]

    /// 이번에 `onImpressionExit()`를 호출해야 하는 엔트리.
    ///
    /// 진입이 실제로 발화된(`tracksExit == true`) 엔트리 중 더 이상 가시 상태가 아닌 것들입니다.
    let entriesToExit: [ImpressionEntry]

    /// 다음 비교에 사용할 가시 스냅샷.
    let snapshot: Set<ImpressionEntry>

    /// 다음 비교에 사용할, 진입이 발화되고 아직 이탈하지 않은 롱임프레션 엔트리 집합.
    let enteredEntries: Set<ImpressionEntry>
  }

  /// 신규 진입(`currentlyVisible` 중 `lastSnapshot`에 없던) 엔트리 중 정책이 허용하는 것을 진입 발화 대상으로,
  /// 진입이 발화됐던(`enteredEntries`) 엔트리 중 더 이상 가시 상태가 아닌 것을 이탈 발화 대상으로 결정합니다.
  ///
  /// 진입이 정책에 의해 차단된 엔트리는 `enteredEntries`에 들어가지 않으므로 이탈이 발화되지 않습니다.
  /// 이탈 대상은 `tracksExit == true`로 진입이 발화된 엔트리에서만 나오므로, 단발성 엔트리는 이탈을 만들지 않습니다.
  ///
  /// - Parameters:
  ///   - currentlyVisible: 현재 가시 상태로 보고된 엔트리 집합.
  ///   - lastSnapshot: 직전에 처리한 가시 스냅샷.
  ///   - enteredEntries: 진입이 발화되고 아직 이탈하지 않은 롱임프레션 엔트리 집합.
  ///   - allowsImpression: 아이템 식별자에 대한 정책 판정. `nil`이면 게이팅 없이 모두 허용합니다.
  /// - Returns: 진입/이탈 발화 대상과, 갱신된 다음 스냅샷·진입 집합.
  func execute(
    currentlyVisible: Set<ImpressionEntry>,
    lastSnapshot: Set<ImpressionEntry>,
    enteredEntries: Set<ImpressionEntry>,
    allowsImpression: ((AnyHashable) -> Bool)?,
  ) -> Decision {
    let added = currentlyVisible.subtracting(lastSnapshot)
    let entriesToFire = added.filter { allowsImpression?($0.item.id) ?? true }

    let visibleIDs = Set(currentlyVisible.map(\.item.id))
    let entriesToExit = enteredEntries.filter { !visibleIDs.contains($0.item.id) }

    // 계속 가시 중인 진입 엔트리는 매 tick `currentlyVisible`에서 프레시하게 재구성해,
    // 이탈 시점에 첫 진입이 아닌 최신 클로저 캡처로 `onImpressionExit`가 발화되도록 합니다.
    let nextEnteredIDs = Set(enteredEntries.subtracting(entriesToExit).map(\.item.id))
      .union(entriesToFire.filter(\.item.tracksExit).map(\.item.id))
    let nextEntered = currentlyVisible.filter { nextEnteredIDs.contains($0.item.id) }

    return Decision(
      entriesToFire: Array(entriesToFire),
      entriesToExit: Array(entriesToExit),
      snapshot: currentlyVisible,
      enteredEntries: nextEntered,
    )
  }
}

