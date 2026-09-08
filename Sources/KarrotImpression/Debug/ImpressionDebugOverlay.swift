//
//  Created by Owen.lee on 7/14/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

#if DEBUG
import UIKit

/// 노출 측정 영역(`trackingRect`)과 safe area를 화면 위에 사각형으로 그려주는 디버깅 오버레이예요.
///
/// FLEX 글로벌 메뉴의 `Impression Debug Overlay` 항목에서 영역별로 토글해요.
/// 측정 영역(주황)은 `ImpressionEventTracker`가 노출 판정에 실제로 사용한 rect를 판정 시점마다 보고받아 그리고,
/// safe area(시안)는 최상단 화면의 `UIView.safeAreaLayoutGuide.layoutFrame`을 주기적으로 읽어 그려요.
///
/// 시트로 덮여도 `viewDidDisappear`가 오지 않는 화면은 트래커가 판정을 계속하는 동안 rect가 유지돼요.
/// 이는 실제 측정 동작을 그대로 반영하는 것이라 라벨의 화면 이름으로 구분해요.
final class ImpressionDebugOverlay {

  /// 앱 곳곳의 `ImpressionEventTracker`가 보고하고 FLEX 설정 화면이 토글하는 상태를 한곳에서 공유하도록 singleton으로 접근해요.
  static let shared = ImpressionDebugOverlay()

  /// 노출 측정 영역(주황) 표시 여부를 의미해요. main thread에서만 읽고 써요.
  var showsTrackingRect = false {
    didSet { updateActivation() }
  }

  /// 최상단 화면 safe area(시안) 표시 여부를 의미해요. main thread에서만 읽고 써요.
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

  /// 마지막으로 그린 내용의 스냅샷이에요. timer 주기마다 내용이 같은데도
  /// 라벨과 레이어를 다시 만드는 낭비를 막는 비교 기준으로 사용해요.
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

  /// `ImpressionEventTracker`가 노출 판정에 사용한 `trackingRect`를 보고해요. `rect`는 window 좌표 기준이에요.
  ///
  /// 트래커가 main으로 수렴해서 호출하지만, 새 호출 경로가 스레드를 보장하지 않아도 안전하도록 여기서도 main을 보장해요.
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

  /// `ImpressionEventTracker`에 `viewController` 없이 등록되어 `sourceIdentifier`가 없는 트래커는
  /// 스크롤뷰의 responder chain에서 가장 가까운 화면 이름을 찾아 라벨로 사용해요.
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

  /// 화면에서 사라진 트래커의 `trackingRect`를 오버레이에서 제거해요.
  ///
  /// 트래커의 `deinit`처럼 스레드가 보장되지 않는 경로에서도 불릴 수 있어 main으로 수렴해요.
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
    // 토글을 끌 때 보관한 rect도 비워, 다시 켰을 때 이전 화면의 stale rect가 그려지지 않게 해요.
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

    // safe area 갱신, 화면에서 내려간 스크롤뷰 정리, status bar 동기화를 위해 짧은 주기로 다시 그려요.
    // 드래그 중(UITrackingRunLoopMode)에도 갱신이 멈추지 않도록 `.common` 모드로 등록해요.
    if refreshTimer == nil {
      let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
        guard let self else { return }
        // 토글 시점에 씬이 준비되지 않아 window 생성에 실패했다면 주기마다 다시 시도해요.
        makeWindowIfNeeded()
        sweepStaleEntries()
        syncMirroredAppearance()
        // 직접 그리지 않고 코얼레싱 경로로 합류해서, 판정 보고가 예약한 redraw와 한 번으로 합쳐지게 해요.
        setNeedsRedraw()
      }
      // 정밀한 발화 시각이 중요한 도구가 아니라서, OS가 다른 timer와 묶어 깨울 수 있게 여유를 줘요.
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
    // 풀스크린 window가 status bar appearance 결정권을 가로채지 않도록, 앱이 실제로 쓰던 값을 그대로 따라가요.
    // pageSheet처럼 결정권을 가져가지 않는 모달에서는 presenting 화면이 기준이라, leaf가 아닌 전용 resolver로 찾아요.
    rootViewController.statusBarStyleSource = { [weak self] in
      self?.statusBarControllingViewController { $0.childForStatusBarStyle }
    }
    rootViewController.statusBarHiddenSource = { [weak self] in
      self?.statusBarControllingViewController { $0.childForStatusBarHidden }
    }
    // home indicator 자동 숨김과 가장자리 제스처 선호값도 이 window가 가로채므로, 앱 최상단 화면의 값을 따라가요.
    rootViewController.systemGesturePreferenceSource = { [weak self] in
      self?.appTopmostViewController()
    }
    // 회전이나 window 리사이즈 시 판정 시점의 window 좌표 스냅샷이 무효가 되므로,
    // 다음 판정이 새 rect를 보고할 때까지 기존 rect를 지워요.
    rootViewController.onContainerSizeChange = { [weak self] in
      guard let self else { return }
      trackingEntries.removeAll()
      setNeedsRedraw()
    }

    let window = UIWindow(windowScene: scene)
    window.rootViewController = rootViewController
    // 앱 콘텐츠 window 위에 겹치되 status bar는 가리지 않도록, status bar 바로 아래 level에 둬요.
    window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue - 10)
    window.isUserInteractionEnabled = false
    // 터치 차단만으로는 접근성 순회가 막히지 않아서, VoiceOver가 오버레이 라벨에 포커스를 잡지 않도록 숨겨요.
    window.accessibilityElementsHidden = true
    window.isHidden = false
    self.window = window
    // 새 window의 view는 비어 있으므로, 이전 window에서 그린 스냅샷과 비교해 그리기를 건너뛰지 않게 초기화해요.
    lastDrawnState = nil
  }

  /// window에서 떨어진 스크롤뷰의 rect를 정리해요. `viewController` 없이 등록된 트래커는
  /// `viewDidDisappear` 시점의 `clearTrackingRect(key:)` 보고가 없어서, timer 주기마다 여기서 걸러내요.
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

  /// 오버레이와 FLEX 같은 보조 window를 제외한 앱 콘텐츠 window를 반환해요.
  ///
  /// `SceneSearcher.topmost`는 keyWindow에서 출발해서 FLEX window가 key인 동안
  /// 툴 화면을 최상단으로 오인하므로, `.normal` level의 콘텐츠 window를 직접 찾아요.
  private var appMainWindow: UIWindow? {
    window?.windowScene?.windows
      .first { $0 !== window && !$0.isHidden && $0.windowLevel == .normal }
  }

  /// 앱 콘텐츠 window 기준의 최상단 화면을 반환해요.
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

  /// UIKit이 status bar appearance 결정권자를 찾는 규칙을 앱 콘텐츠 window 기준으로 재현해요.
  ///
  /// presented 화면은 `.fullScreen`이거나 `UIViewController.modalPresentationCapturesStatusBarAppearance`를
  /// 켠 경우에만 결정권을 가져가요. `appTopmostViewController()`는 presented를 무조건 따라가서,
  /// pageSheet처럼 결정권이 없는 모달이 떠 있는 동안 미러 값이 실제와 어긋나요.
  /// 시트가 presenting 화면을 축소하는 동안 시스템이 스타일을 보정하는 세부 동작까지는 재현하지 않아요.
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

  /// 스크롤 중 트래커 보고가 프레임마다 여러 번 와도 runloop turn당 한 번만 다시 그리도록 합쳐요.
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
    // 내용이 그대로면 뷰 재구성을 건너뛰어, 유휴 화면에서 timer 주기마다 도구 자신이 CPU를 쓰지 않게 해요.
    guard state != lastDrawnState else { return }
    lastDrawnState = state

    containerView.subviews.forEach { $0.removeFromSuperview() }

    for region in state.trackingRegions {
      containerView.addSubview(
        makeRegionView(region: region, color: .systemOrange, style: .solid, labelPlacement: .topLeading)
      )
    }

    // 두 영역이 같은 경계선에 겹칠 때 둘 다 보이도록, safe area는 dashed border로 위에 그려요.
    if let safeAreaRegion = state.safeAreaRegion {
      containerView.addSubview(
        makeRegionView(region: safeAreaRegion, color: .systemCyan, style: .dashed, labelPlacement: .bottomLeading)
      )
    }
  }

  /// 같은 rect를 쓰는 트래커들(셀 내부 캐러셀처럼 부모 rect를 공유하는 경우)을 하나의 영역으로 합쳐요.
  /// fill이 겹겹이 쌓여 점점 진해지는 것을 막고, 중복 개수는 라벨의 `×N`으로 표시해요.
  private func groupedTrackingRegions() -> [Region] {
    var groups: [RectKey: TrackingGroup] = [:]
    for entry in trackingEntries.values {
      let key = RectKey(entry.rect)
      // 반올림 없이 좌표 원본을 키로 사용해요. 소수점 차이는 측정 영역 불일치의 단서라 합치지 않고 따로 그려요.
      if var group = groups[key] {
        group.count += 1
        group.labels.insert(entry.label)
        groups[key] = group
      } else {
        groups[key] = TrackingGroup(rect: entry.rect, labels: [entry.label], count: 1)
      }
    }

    return groups.values.map { group in
      // 서로 다른 화면의 트래커가 같은 rect를 보고해도 출처가 가려지지 않도록 라벨을 전부 나열해요.
      let joinedLabels = group.labels.sorted().joined(separator: " · ")
      let countSuffix = group.count > 1 ? " ×\(group.count)" : ""
      return Region(
        rect: group.rect,
        title: "\(joinedLabels)\(countSuffix) (y \(Self.format(group.rect.minY))~\(Self.format(group.rect.maxY)))"
      )
    }
    // dictionary 순회 순서가 매번 달라지지 않도록 정렬해서, redraw 스킵 비교가 안정적으로 동작하게 해요.
    .sorted {
      ($0.title, $0.rect.minY, $0.rect.minX) < ($1.title, $1.rect.minY, $1.rect.minX)
    }
  }

  /// 정수 좌표는 그대로, 소수 좌표는 뒤따르는 0을 지우고 셋째 자리까지 표시해요.
  /// 소수점 차이가 곧 불일치 단서라, 미세하게 어긋난 rect들의 라벨이 같은 값으로 보이지 않게 해요.
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

    // `viewIfLoaded`로 timer가 view 로드를 강제하는 부작용을 막고,
    // window 좌표 변환(`convert(_:to: nil)`)이 유효하도록 window에 붙은 view만 사용해요.
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

/// 오버레이 window의 root로 앉는 투명 컨테이너예요.
/// 풀스크린 window가 status bar와 시스템 제스처 선호값의 결정권을 가져가는 UIKit 동작을,
/// 앱 화면의 값을 미러링해서 상쇄해요.
private final class OverlayRootViewController: UIViewController {

  /// status bar style을 따라갈 앱 화면을 제공해요.
  var statusBarStyleSource: (() -> UIViewController?)?
  /// status bar 숨김 여부를 따라갈 앱 화면을 제공해요.
  var statusBarHiddenSource: (() -> UIViewController?)?
  /// home indicator 자동 숨김과 가장자리 제스처 선호값을 따라갈 앱 최상단 화면을 제공해요.
  var systemGesturePreferenceSource: (() -> UIViewController?)?
  /// 회전이나 window 리사이즈로 오버레이 좌표계가 바뀔 때 호출돼요.
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

