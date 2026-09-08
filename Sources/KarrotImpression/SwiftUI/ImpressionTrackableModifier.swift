//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

/// 개별 아이템의 가시 비율을 계산하고, `ImpressionVisibilityPreferenceKey`를 통해 컨테이너에 보고하는 자식 modifier.
///
/// `onGeometryChange`로 자신의 프레임과 컨테이너 `impressionContainerFrame`의 교차 면적 비율을 계산하여,
/// `visibilityThreshold` 이상이면 가시 상태로 판정합니다.
/// `onAppear`/`onDisappear`로 뷰의 활성 상태를 관리하며, 비활성 시 가시성을 `false`로 보고합니다.
/// 가시성 판정과 보고만 담당하며, 임프레션 발생 여부는 컨테이너가 결정합니다.
struct ImpressionTrackableModifier: ViewModifier {

  let item: ImpressionItem
  let onImpressionEnter: () -> Void
  var onImpressionExit: (() -> Void)? = nil
  @State private var isActive = false
  @State private var isVisible = false
  @Environment(\.impressionContainerFrame) private var containerFrame
  #if DEBUG
  @Environment(\.impressedItemIDs) private var impressedItemIDs
  #endif

  func body(content: Content) -> some View {
    content
      .onAppear {
        isActive = true
      }
      .onDisappear {
        isActive = false
        isVisible = false
      }
      .onGeometryChange(for: Bool.self) { proxy in
        guard isActive else { return false }

        let frame = proxy.frame(in: .global)
        let visibleRatio = visibleRatio(
          frame: frame,
          containerFrame: containerFrame,
        )
        return visibleRatio > 0 && visibleRatio >= item.visibilityThreshold
      } action: { newValue in
        isVisible = newValue
      }
      .preference(
        key: ImpressionVisibilityPreferenceKey.self,
        value: [
          ImpressionEntry(
            item: item,
            isVisible: isVisible,
            onImpressionEnter: onImpressionEnter,
            onImpressionExit: onImpressionExit,
          )
        ] as Set,
      )
    #if DEBUG
      .showsImpressionRect(isVisible: impressedItemIDs.contains(item.id))
    #endif
  }

  /// 아이템 프레임과 컨테이너 가시 영역의 교차 면적 비율을 계산합니다.
  private func visibleRatio(frame: CGRect, containerFrame: CGRect) -> CGFloat {
    let itemArea = frame.width * frame.height
    if itemArea == .zero {
      return .zero
    }

    let intersection = containerFrame.intersection(frame)
    if intersection.isEmpty {
      return .zero
    }

    return (intersection.width * intersection.height) / itemArea
  }
}

