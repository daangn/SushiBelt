//
//  Created by Owen.lee on 7/14/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

#if DEBUG
import SwiftUI
import UIKit

/// Toggles overlays for UIKit tracking areas and the topmost screen's safe area.
/// Push or present this view controller from your app's debug menu in `DEBUG` builds.
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

/// Groups overlay toggles by region, with a legend matching each drawing style.
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

/// Previews the orange tracking fill and cyan dashed safe-area border.
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
