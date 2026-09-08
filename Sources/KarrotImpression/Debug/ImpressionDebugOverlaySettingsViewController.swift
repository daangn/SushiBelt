//
//  Created by Owen.lee on 7/14/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

#if DEBUG
import SwiftUI
import UIKit

/// 노출 추적 영역과 최상위 화면의 safe area 표시를 켜고 끄는 디버그 설정 화면이에요.
/// `DEBUG` 빌드에서 생성해 navigation stack에 push하거나 present할 수 있어요.
public final class ImpressionDebugOverlaySettingsViewController: UIViewController {

  public init() {
    super.init(nibName: nil, bundle: nil)
    title = "Impression Debug Overlay"
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    let hostingController = UIHostingController(rootView: ImpressionDebugOverlaySettingsView())
    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.view.frame = view.bounds
    hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostingController.didMove(toParent: self)
  }
}

/// 오버레이 토글을 영역별 섹션으로 나눠 보여주는 설정 화면 본문이에요.
/// 각 행은 오버레이가 실제로 그리는 스타일을 미리 보여주는 legend, 제목과 설명, 토글로 구성해요.
private struct ImpressionDebugOverlaySettingsView: View {

  @State private var showsTrackingRect = ImpressionDebugOverlay.shared.showsTrackingRect
  @State private var showsSafeArea = ImpressionDebugOverlay.shared.showsSafeArea

  var body: some View {
    List {
      Section {
        OverlayToggleRow(
          legend: .trackingRect,
          title: "Tracking Rect",
          subtitle: "The rect each impression tracker actually uses for visibility detection.",
          isOn: $showsTrackingRect,
        )
      } header: {
        Text("Impression")
          .font(.system(size: 14))
      } footer: {
        Text(
          """
          Reported at every detection pass — scroll or re-enter the screen to see it. \
          Trackers sharing the same rect merge into one region with an ×N count in the label.
          """
        )
        .font(.system(size: 14))
      }

      Section {
        OverlayToggleRow(
          legend: .safeArea,
          title: "Safe Area",
          subtitle: "The top-most screen's safe area layout frame.",
          isOn: $showsSafeArea,
        )
      } header: {
        Text("Layout")
          .font(.system(size: 14))
      } footer: {
        Text(
          """
          Follows the screen on top as you navigate, refreshed every 0.25 seconds. \
          The label shows the current top/bottom inset values.
          """
        )
        .font(.system(size: 14))
      }
    }
    .listStyle(.insetGrouped)
    .onChange(of: showsTrackingRect) { _, newValue in
      ImpressionDebugOverlay.shared.showsTrackingRect = newValue
    }
    .onChange(of: showsSafeArea) { _, newValue in
      ImpressionDebugOverlay.shared.showsSafeArea = newValue
    }
  }
}

// MARK: - Rows

private struct OverlayToggleRow: View {

  enum Legend {
    case trackingRect
    case safeArea
  }

  let legend: Legend
  let title: String
  let subtitle: String
  @Binding var isOn: Bool

  var body: some View {
    HStack(spacing: 12) {
      LegendSwatch(legend: legend)
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 16))
        Text(subtitle)
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
      }
      Spacer()
      Toggle(title, isOn: $isOn)
        .labelsHidden()
    }
    .padding(.vertical, 4)
  }
}

/// 오버레이가 그리는 스타일(주황 solid fill, 시안 dashed border)을 축소해서 보여주는 미리보기예요.
private struct LegendSwatch: View {

  let legend: OverlayToggleRow.Legend

  var body: some View {
    switch legend {
    case .trackingRect:
      RoundedRectangle(cornerRadius: 6)
        .fill(Color(uiColor: .systemOrange).opacity(0.15))
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Color(uiColor: .systemOrange), lineWidth: 2)
        )
        .frame(width: 32, height: 32)

    case .safeArea:
      RoundedRectangle(cornerRadius: 6)
        .strokeBorder(
          Color(uiColor: .systemCyan),
          style: StrokeStyle(lineWidth: 2, dash: [4, 3])
        )
        .frame(width: 32, height: 32)
    }
  }
}
#endif
