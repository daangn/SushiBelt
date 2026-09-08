//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// 임프레션 추적 영역을 관리하는 컨테이너 modifier.
///
/// 뷰 라이프사이클(`viewDidAppear` / `onDisappear`)과 앱 라이프사이클(`UIApplication` Notification)을 결합하여
/// 활성 상태를 제어하고, `onGeometryChange`로 가시 영역(`containerFrame`)을 측정합니다.
///
/// 자식 뷰들은 `ImpressionVisibilityPreferenceKey`를 통해 가시성 상태를 보고하고,
/// 이 modifier가 중복 방지와 정책 확인을 수행합니다.
///
/// 임프레션 상태는 세 가지로 분리해 관리합니다: 재진입 diff용 `lastImpressionSnapshot`(정책 차단
/// 엔트리도 포함해 재평가를 막음), 정책 게이팅용 `ImpressionPolicy.Storage`, 그리고 이탈을 정확히
/// 한 번 발화하기 위한 `enteredEntries`(진입이 실제 발화된 `tracksExit` 엔트리만). 이탈 후보는 오직
/// `enteredEntries`에서만 나오므로 정책 차단·단발성 엔트리는 유령 이탈을 만들지 않습니다.
struct ImpressionTrackingContainerModifier: ViewModifier {

  /// `onPreferenceChange`에서 연속적으로 발생하는 preference 변경을 debounce하기 위한 저장소.
  ///
  /// 이전 작업을 취소하고 최신 작업만 실행하여, 중간 오동작 처리를 방지합니다.
  private final class DebouncedWorkItem {
    var workItem: DispatchWorkItem?

    func cancel() {
      workItem?.cancel()
      workItem = nil
    }
  }

  private let visibleArea: VisibleAreaRegion

  @Environment(\.impressionPolicyContext) private var policyContext

  @State private var isActive = false
  @State private var didViewAppear = false
  @State private var isDisappearing = false

  @State private var containerFrame: CGRect = .zero

  /// 자식 뷰들이 preference를 통해 보고한 현재 가시 아이템.
  /// `isActive` 상태와 무관하게 항상 최신 값을 유지합니다.
  @State private var visibleEntries: Set<ImpressionEntry> = []

  /// 마지막으로 임프레션을 처리한 시점의 스냅샷.
  /// diff를 통해 신규 노출 아이템만 식별하는 데 사용됩니다.
  @State private var lastImpressionSnapshot: Set<ImpressionEntry> = []

  /// 진입(`onImpressionEnter`)이 발화되고 아직 이탈하지 않은 롱임프레션(`tracksExit`) 엔트리.
  /// 이탈을 정확히 한 번 발화하기 위해 스냅샷과 별개로 유지합니다.
  @State private var enteredEntries: Set<ImpressionEntry> = []

  @State private var debouncedWorkItem: DebouncedWorkItem = .init()

  private let didBecomeActiveNotification = NotificationCenter.default
    .publisher(for: UIApplication.didBecomeActiveNotification)
  private let didEnterBackgroundNotification = NotificationCenter.default
    .publisher(for: UIApplication.didEnterBackgroundNotification)

  init(
    visibleArea: VisibleAreaRegion = .ignoringSafeArea()
  ) {
    self.visibleArea = visibleArea
  }

  func body(content: Content) -> some View {
    content
      .onDidAppear {
        didViewAppear = true
        isDisappearing = false

        isActive = true
      } onDisappearing: {
        didViewAppear = false
        isDisappearing = true
      }
      .onDisappear {
        didViewAppear = false
        isDisappearing = false

        isActive = false
      }
      .onReceive(didEnterBackgroundNotification) { _ in
        isActive = false
      }
      .onReceive(didBecomeActiveNotification) { _ in
        isActive = didViewAppear
      }
      .onChange(of: isActive) { newValue in
        if newValue {
          processImpressionTransitions(for: visibleEntries)
        } else {
          exitEnteredImpressions()
          lastImpressionSnapshot.removeAll()
        }
      }
      .background {
        Color.clear
          .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
          } action: { rect in
            if isDisappearing {
              return
            }

            containerFrame = rect
          }
          .ignoresSafeArea(visibleArea.safeAreaRegions, edges: visibleArea.safeAreaEdges)
      }
      .onPreferenceChange(ImpressionVisibilityPreferenceKey.self) { entries in
        if isDisappearing {
          return
        }

        debouncedWorkItem.cancel()
        let workItem = DispatchWorkItem {
          visibleEntries = entries.filter(\.isVisible)
        }
        debouncedWorkItem.workItem = workItem
        DispatchQueue.main.async(execute: workItem)
      }
      .onChange(of: visibleEntries) { newValue in
        guard isActive else { return }
        processImpressionTransitions(for: newValue)
      }
      .environment(\.impressionContainerFrame, containerFrame)
    #if DEBUG
      .environment(\.impressedItemIDs, Set(lastImpressionSnapshot.map(\.item.id)))
    #endif
  }

  // MARK: - Private

  private func processImpressionTransitions(for entries: Set<ImpressionEntry>) {
    let decision = ImpressionFiringDecideUseCase().execute(
      currentlyVisible: entries,
      lastSnapshot: lastImpressionSnapshot,
      enteredEntries: enteredEntries,
      allowsImpression: policyContext.map { context in
        { context.allowsImpression(for: $0) }
      },
    )

    // 이탈을 진입보다 먼저 발화해, 같은 tick 안에서 이탈→진입 순서를 자연스럽게 유지합니다.
    for entry in decision.entriesToExit {
      entry.onImpressionExit?()
    }
    for entry in decision.entriesToFire {
      entry.onImpressionEnter()
    }
    lastImpressionSnapshot = decision.snapshot
    enteredEntries = decision.enteredEntries
  }

  /// 컨테이너 비활성화(백그라운드 전환·뷰 이탈) 시 아직 이탈하지 않은 롱임프레션을 best-effort로 이탈시킵니다.
  /// 크래시·강제 종료로 인한 유실은 허용되므로 보정하지 않습니다.
  /// 이탈 콜백 순서는 `Set` 순회에 의존해 규정하지 않습니다(개별 이탈 이벤트는 서로 독립적).
  private func exitEnteredImpressions() {
    for entry in enteredEntries {
      entry.onImpressionExit?()
    }
    enteredEntries.removeAll()
  }
}

