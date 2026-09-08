//
//  Created by Owen.lee on 7/14/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

#if DEBUG
import UIKit

/// Draws UIKit tracking areas and the topmost screen's safe area over app content.
///
/// `ImpressionDebugOverlaySettingsViewController` controls the two overlays.
/// Orange rects come from trackers on each detection pass. The cyan rect is
/// sampled periodically from the topmost view's safe-area layout guide.
///
/// A screen covered by a sheet can keep reporting until `viewDidDisappear`.
/// Screen labels identify these overlapping tracking areas.
final class ImpressionDebugOverlay {

  /// Shares reports and settings across all trackers in the app.
  static let shared = ImpressionDebugOverlay()

  /// Controls the orange tracking-area overlay. Access only on the main thread.
  var showsTrackingRect = false {
    didSet { updateActivation() }
  }

  /// Controls the cyan safe-area overlay. Access only on the main thread.
  var showsSafeArea = false {
    didSet { updateActivation() }
  }

  private struct Region: Equatable {
    var rect: CGRect
    var title: String
  }

  private struct TrackingEntry {
    weak var scrollView: UIScrollView?
    var rect: CGRect
    var label: String
  }

  private struct TrackingGroup {
    var rect: CGRect
    var labels: Set<String>
    var count: Int
  }

  private struct RectKey: Hashable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    init(_ rect: CGRect) {
      x = rect.origin.x
      y = rect.origin.y
      width = rect.size.width
      height = rect.size.height
    }
  }

  /// Avoids rebuilding labels and layers when the timer observes unchanged content.
  private struct DrawnState: Equatable {
    var trackingRegions: [Region]
    var safeAreaRegion: Region?
  }

  private var trackingEntries: [UUID: TrackingEntry] = [:]
  private var window: UIWindow?
  private var refreshTimer: Timer?
  private var needsRedraw = false
  private var lastDrawnState: DrawnState?

  private init() {}

  // MARK: - Reporting

  /// Records a tracker's detection area in window coordinates.
  ///
  /// Dispatches to the main thread even when the caller does not.
  func reportTrackingRect(
    _ rect: CGRect,
    key: UUID,
    scrollView: UIScrollView?,
    sourceIdentifier: String?,
  ) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak scrollView] in
        self.reportTrackingRect(rect, key: key, scrollView: scrollView, sourceIdentifier: sourceIdentifier)
      }
      return
    }

    guard showsTrackingRect else { return }
    let label = sourceIdentifier ?? Self.fallbackLabel(for: scrollView)
    trackingEntries[key] = TrackingEntry(scrollView: scrollView, rect: rect, label: label)
    setNeedsRedraw()
  }

  /// Finds a screen label through the responder chain when no view controller was registered.
  private static func fallbackLabel(for scrollView: UIScrollView?) -> String {
    guard let scrollView else { return "Unknown" }
    let scrollViewName = String(describing: type(of: scrollView))

    if let viewController = sequence(first: scrollView as UIResponder, next: \.next)
      .lazy.compactMap({ $0 as? UIViewController }).first
    {
      return "\(String(describing: type(of: viewController))) / \(scrollViewName)"
    }
    return scrollViewName
  }

  /// Removes a tracker's area from the overlay.
  ///
  /// Dispatches to the main thread because cleanup can run from a tracker's deinitializer.
  func clearTrackingRect(key: UUID) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.clearTrackingRect(key: key)
      }
      return
    }

    guard trackingEntries.removeValue(forKey: key) != nil else { return }
    setNeedsRedraw()
  }

  // MARK: - Activation

  private func updateActivation() {
    // Discard old rects so reenabling the overlay cannot show a previous screen's geometry.
    if !showsTrackingRect {
      trackingEntries.removeAll()
    }

    guard showsTrackingRect || showsSafeArea else {
      refreshTimer?.invalidate()
      refreshTimer = nil
      window?.isHidden = true
      window = nil
      lastDrawnState = nil
      return
    }

    makeWindowIfNeeded()

    // Refresh safe-area geometry, remove detached scroll views, and mirror system appearance.
    // Common run-loop modes keep these updates running during dragging.
    if refreshTimer == nil {
      let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
        guard let self else { return }
        // Retry if no active scene was available when the overlay was enabled.
        makeWindowIfNeeded()
        sweepStaleEntries()
        syncMirroredAppearance()
        // Coalesce with redraws already requested by tracker reports.
        setNeedsRedraw()
      }
      // Exact timing is not required; let the system coalesce timer wakeups.
      timer.tolerance = 0.05
      RunLoop.main.add(timer, forMode: .common)
      refreshTimer = timer
    }

    setNeedsRedraw()
  }

  private func makeWindowIfNeeded() {
    guard window == nil else { return }
    guard
      let scene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive })
    else {
      return
    }

    let rootViewController = OverlayRootViewController()
    // Mirror the app's status bar appearance instead of replacing it with this window's defaults.
    // A sheet may leave control with its presenter, so the topmost controller is not always the source.
    rootViewController.statusBarStyleSource = { [weak self] in
      self?.statusBarControllingViewController { $0.childForStatusBarStyle }
    }
    rootViewController.statusBarHiddenSource = { [weak self] in
      self?.statusBarControllingViewController { $0.childForStatusBarHidden }
    }
    // Mirror home-indicator and edge-gesture preferences from the app's topmost controller.
    rootViewController.systemGesturePreferenceSource = { [weak self] in
      self?.appTopmostViewController()
    }
    // Rotation and resizing invalidate window-coordinate snapshots; wait for fresh reports.
    rootViewController.onContainerSizeChange = { [weak self] in
      guard let self else { return }
      trackingEntries.removeAll()
      setNeedsRedraw()
    }

    let window = UIWindow(windowScene: scene)
    window.rootViewController = rootViewController
    // Draw above app content but below the status bar.
    window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue - 10)
    window.isUserInteractionEnabled = false
    // Disabling touch handling alone does not prevent VoiceOver from focusing the labels.
    window.accessibilityElementsHidden = true
    window.isHidden = false
    self.window = window
    // The new window is empty even if its content matches the previous snapshot.
    lastDrawnState = nil
  }

  /// Removes rects for detached scroll views, including trackers without a view-controller lifecycle.
  private func sweepStaleEntries() {
    let staleKeys = trackingEntries.filter { $0.value.scrollView?.window == nil }.map(\.key)
    guard !staleKeys.isEmpty else { return }
    for key in staleKeys {
      trackingEntries.removeValue(forKey: key)
    }
  }

  private func syncMirroredAppearance() {
    guard let rootViewController = window?.rootViewController else { return }
    rootViewController.setNeedsStatusBarAppearanceUpdate()
    rootViewController.setNeedsUpdateOfHomeIndicatorAutoHidden()
    rootViewController.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
  }

  // MARK: - App Window

  /// Finds an app content window, excluding this overlay and higher-level utility windows.
  ///
  /// A utility window can be key, so search for a visible normal-level window instead.
  private var appMainWindow: UIWindow? {
    window?.windowScene?.windows
      .first { $0 !== window && !$0.isHidden && $0.windowLevel == .normal }
  }

  /// Finds the topmost view controller in the app content window.
  private func appTopmostViewController() -> UIViewController? {
    guard var controller = appMainWindow?.rootViewController else { return nil }
    while true {
      let next: UIViewController?
      if let presented = controller.presentedViewController, !presented.isBeingDismissed {
        next = presented
      } else if let navigation = controller as? UINavigationController {
        next = navigation.topViewController
      } else if let tab = controller as? UITabBarController {
        next = tab.selectedViewController
      } else if let split = controller as? UISplitViewController {
        next = split.viewControllers.last
      } else if let page = controller as? UIPageViewController {
        next = page.viewControllers?.first
      } else {
        next = controller.children.last {
          guard let parentView = controller.viewIfLoaded, let childView = $0.viewIfLoaded else { return false }
          return childView.frame == parentView.bounds
        }
      }
      guard let next, next !== controller else { return controller }
      controller = next
    }
  }

  /// Resolves status bar appearance from the app content window's controller hierarchy.
  ///
  /// Follow presented controllers only for full-screen presentations or when they
  /// capture status bar appearance. Always following the topmost controller would
  /// pick sheets that do not own that appearance. System adjustments while a sheet
  /// scales its presenter are not reproduced here.
  private func statusBarControllingViewController(
    child childProvider: (UIViewController) -> UIViewController?,
  ) -> UIViewController? {
    guard var controller = appMainWindow?.rootViewController else { return nil }
    while true {
      if
        let presented = controller.presentedViewController,
        !presented.isBeingDismissed,
        presented.modalPresentationStyle == .fullScreen
          || presented.modalPresentationCapturesStatusBarAppearance
      {
        controller = presented
        continue
      }
      if let child = childProvider(controller), child !== controller {
        controller = child
        continue
      }
      return controller
    }
  }

  // MARK: - Drawing

  /// Coalesces multiple tracker reports into one redraw per main-queue turn.
  private func setNeedsRedraw() {
    guard !needsRedraw else { return }
    needsRedraw = true
    DispatchQueue.main.async { [weak self] in
      guard let self, needsRedraw else { return }
      needsRedraw = false
      redrawNow()
    }
  }

  private func redrawNow() {
    guard let containerView = window?.rootViewController?.view else { return }

    let state = DrawnState(
      trackingRegions: showsTrackingRect ? groupedTrackingRegions() : [],
      safeAreaRegion: showsSafeArea ? currentSafeAreaRegion() : nil
    )
    // Avoid rebuilding views on every timer tick while the content is unchanged.
    guard state != lastDrawnState else { return }
    lastDrawnState = state

    containerView.subviews.forEach { $0.removeFromSuperview() }

    for region in state.trackingRegions {
      containerView.addSubview(
        makeRegionView(region: region, color: .systemOrange, style: .solid, labelPlacement: .topLeading)
      )
    }

    // A dashed safe-area border keeps both outlines visible when their edges overlap.
    if let safeAreaRegion = state.safeAreaRegion {
      containerView.addSubview(
        makeRegionView(region: safeAreaRegion, color: .systemCyan, style: .dashed, labelPlacement: .bottomLeading)
      )
    }
  }

  /// Groups identical rects so shared tracking areas do not accumulate darker fills.
  /// The label's `×N` suffix shows the number of reports sharing the rect.
  private func groupedTrackingRegions() -> [Region] {
    var groups: [RectKey: TrackingGroup] = [:]
    for entry in trackingEntries.values {
      let key = RectKey(entry.rect)
      // Preserve fractional differences that can reveal mismatched tracking areas.
      if var group = groups[key] {
        group.count += 1
        group.labels.insert(entry.label)
        groups[key] = group
      } else {
        groups[key] = TrackingGroup(rect: entry.rect, labels: [entry.label], count: 1)
      }
    }

    return groups.values.map { group in
      // Keep all source labels when multiple screens report the same rect.
      let joinedLabels = group.labels.sorted().joined(separator: " · ")
      let countSuffix = group.count > 1 ? " ×\(group.count)" : ""
      return Region(
        rect: group.rect,
        title: "\(joinedLabels)\(countSuffix) (y \(Self.format(group.rect.minY))~\(Self.format(group.rect.maxY)))"
      )
    }
    // Stable ordering makes the drawn-state comparison independent of dictionary iteration order.
    .sorted {
      ($0.title, $0.rect.minY, $0.rect.minX) < ($1.title, $1.rect.minY, $1.rect.minX)
    }
  }

  /// Shows up to three decimal places without trailing zeros to expose small geometry differences.
  private static func format(_ value: CGFloat) -> String {
    if value == value.rounded() {
      return String(format: "%.0f", value)
    }
    var formatted = String(format: "%.3f", value)
    while formatted.hasSuffix("0") {
      formatted.removeLast()
    }
    if formatted.hasSuffix(".") {
      formatted.removeLast()
    }
    return formatted
  }

  private func currentSafeAreaRegion() -> Region? {
    guard let topViewController = appTopmostViewController() else { return nil }

    // Do not force view loading from the timer; window conversion also requires an attached view.
    guard let view = topViewController.viewIfLoaded, view.window != nil else { return nil }

    let insets = view.safeAreaInsets
    return Region(
      rect: view.convert(view.safeAreaLayoutGuide.layoutFrame, to: nil),
      title: String(
        format: "%@ safeArea (top %.0f, bottom %.0f)",
        String(describing: type(of: topViewController)),
        insets.top,
        insets.bottom,
      )
    )
  }

  private enum RegionStyle {
    case solid
    case dashed
  }

  private enum LabelPlacement {
    case topLeading
    case bottomLeading
  }

  private func makeRegionView(
    region: Region,
    color: UIColor,
    style: RegionStyle,
    labelPlacement: LabelPlacement,
  ) -> UIView {
    let regionView = UIView(frame: region.rect)

    switch style {
    case .solid:
      regionView.backgroundColor = color.withAlphaComponent(0.08)
      regionView.layer.borderColor = color.cgColor
      regionView.layer.borderWidth = 2

    case .dashed:
      let borderLayer = CAShapeLayer()
      borderLayer.path = UIBezierPath(rect: regionView.bounds).cgPath
      borderLayer.strokeColor = color.cgColor
      borderLayer.fillColor = UIColor.clear.cgColor
      borderLayer.lineWidth = 3
      borderLayer.lineDashPattern = [8, 5]
      regionView.layer.addSublayer(borderLayer)
    }

    let titleLabel = UILabel()
    titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
    titleLabel.text = region.title
    titleLabel.textColor = .black
    titleLabel.backgroundColor = color.withAlphaComponent(0.95)
    titleLabel.sizeToFit()
    titleLabel.frame = titleLabel.frame.insetBy(dx: -2, dy: 0)
    titleLabel.textAlignment = .center
    switch labelPlacement {
    case .topLeading:
      titleLabel.frame.origin = CGPoint(x: 4, y: 4)
    case .bottomLeading:
      titleLabel.frame.origin = CGPoint(x: 4, y: regionView.bounds.height - titleLabel.frame.height - 4)
    }
    regionView.addSubview(titleLabel)

    return regionView
  }
}

// MARK: - OverlayRootViewController

/// A transparent overlay root that mirrors the app's status bar and system-gesture preferences.
private final class OverlayRootViewController: UIViewController {

  /// Supplies the controller whose status bar style should be mirrored.
  var statusBarStyleSource: (() -> UIViewController?)?
  /// Supplies the controller whose status bar visibility should be mirrored.
  var statusBarHiddenSource: (() -> UIViewController?)?
  /// Supplies the controller whose home-indicator and edge-gesture preferences should be mirrored.
  var systemGesturePreferenceSource: (() -> UIViewController?)?
  /// Notifies the overlay when rotation or resizing invalidates its coordinates.
  var onContainerSizeChange: (() -> Void)?

  override var preferredStatusBarStyle: UIStatusBarStyle {
    statusBarStyleSource?()?.preferredStatusBarStyle ?? .default
  }

  override var prefersStatusBarHidden: Bool {
    statusBarHiddenSource?()?.prefersStatusBarHidden ?? false
  }

  override var prefersHomeIndicatorAutoHidden: Bool {
    systemGesturePreferenceSource?()?.prefersHomeIndicatorAutoHidden ?? false
  }

  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    systemGesturePreferenceSource?()?.preferredScreenEdgesDeferringSystemGestures ?? []
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    onContainerSizeChange?()
  }
}
#endif
