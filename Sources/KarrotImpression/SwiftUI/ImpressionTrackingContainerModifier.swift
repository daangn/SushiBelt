//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// Manages an impression-tracking region and its visibility transitions.
///
/// Combines view lifecycle callbacks with app notifications to control tracking
/// activity, and measures `containerFrame` with `onGeometryChange`.
///
/// Children report visibility through `ImpressionVisibilityPreferenceKey`.
/// The container identifies new entries and applies the impression policy.
///
/// `lastImpressionSnapshot` includes policy-suppressed entries to avoid reevaluating
/// them while they remain visible. Policy storage is managed separately.
/// `enteredEntries` contains only fired entries with exit tracking, so suppressed
/// entries and items without exit tracking do not produce exit callbacks.
struct ImpressionTrackingContainerModifier: ViewModifier {

  /// Holds the pending preference update so newer reports can replace it.
  ///
  /// Cancelling the previous work item avoids processing intermediate reports.
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

  /// The latest accepted child visibility report, retained even while tracking is inactive.
  @State private var visibleEntries: Set<ImpressionEntry> = []

  /// The last processed snapshot, used to identify newly visible entries.
  @State private var lastImpressionSnapshot: Set<ImpressionEntry> = []

  /// Fired entries with exit tracking that have not exited yet.
  /// Kept separately from the snapshot to avoid duplicate exit callbacks.
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

    // Process exits before entries within the same update.
    for entry in decision.entriesToExit {
      entry.onImpressionExit?()
    }
    for entry in decision.entriesToFire {
      entry.onImpressionEnter()
    }
    lastImpressionSnapshot = decision.snapshot
    enteredEntries = decision.enteredEntries
  }

  /// Emits outstanding exits when the container becomes inactive.
  /// Delivery is best-effort; crashes and forced termination are not recovered.
  /// Callback order is unspecified because entries are stored in a `Set`.
  private func exitEnteredImpressions() {
    for entry in enteredEntries {
      entry.onImpressionExit?()
    }
    enteredEntries.removeAll()
  }
}

