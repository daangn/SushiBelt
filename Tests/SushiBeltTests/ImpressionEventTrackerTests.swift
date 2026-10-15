//
//  ImpressionEventTrackerTests.swift
//  SushiBeltTests
//
//  Created by 1Consumption on 2026/09/18.
//

import UIKit
import XCTest
@testable import KarrotImpression

final class ImpressionEventTrackerTests: XCTestCase {

  private var detector: VisibleStateDetectorSpy!

  override func setUp() {
    super.setUp()
    self.detector = VisibleStateDetectorSpy()
  }

  override func tearDown() {
    self.detector = nil
    super.tearDown()
  }

  private func makeSUT(usesInitialVisibility: Bool) -> ImpressionEventTracker {
    ImpressionEventTracker(
      detector: self.detector,
      application: UIApplication.self,
      cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }),
      usesInitialVisibility: usesInitialVisibility,
    )
  }
}

extension ImpressionEventTrackerTests {

  func test_창을_확대하면_새로_보이는_아이템만_로깅해요() {
    let sut = ImpressionEventTracker(
      detector: VisibleStateDetector(sushiBeltTracker: SushiBeltTracker(), sushiBeltDebugger: SushiBeltDebuggerSpy()),
      application: UIApplication.self,
      cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }),
      usesInitialVisibility: false
    )
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 800))
    window.addSubview(scrollView)
    let first = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let second = UIView(frame: CGRect(x: 0, y: 250, width: 100, height: 100))
    scrollView.addSubview(first)
    scrollView.addSubview(second)
    let factory = DetectorItemFactoryStub()
    factory.items = [
      VisibleStateDetectorItem(id: "first", target: first, ratio: 1),
      VisibleStateDetectorItem(id: "second", target: second, ratio: 1),
    ]
    sut.register(scrollView: scrollView, detectorItemFactory: factory,
                 trackingRect: { scrollView.convert(scrollView.bounds, to: nil) })
    var logged: [String] = []
    sut.subscribe { logged.append($0.id) }
    sut.trackManually(shouldResetCache: false)
    XCTAssertEqual(logged, ["first"])

    scrollView.frame.size.height = 400
    scrollView.setNeedsLayout()
    scrollView.layoutIfNeeded()

    XCTAssertEqual(logged, ["first", "second"])
    scrollView.frame.size.height = 450
    scrollView.layoutIfNeeded()
    XCTAssertEqual(logged, ["first", "second"])
  }

  func test_collectionView_너비를_늘리면_재배치된_셀의_최신_위치로_즉시_로깅해요() throws {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 100, height: 100)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    let collectionView = UICollectionView(
      frame: CGRect(x: 0, y: 0, width: 200, height: 150),
      collectionViewLayout: layout
    )
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    let dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
      collectionView, indexPath, _ in
      collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
    var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
    snapshot.appendSections([0])
    snapshot.appendItems(Array(0..<6))
    dataSource.applySnapshotUsingReloadData(snapshot)
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 800))
    window.addSubview(collectionView)
    collectionView.layoutIfNeeded()

    var evaluatedFrames: [Int: CGRect] = [:]
    let factory = DefaultDetectorItemFactory { [weak collectionView] view in
      guard let cell = view as? UICollectionViewCell,
        let indexPath = collectionView?.indexPath(for: cell),
        let id = dataSource.itemIdentifier(for: indexPath) else {
        return nil
      }
      evaluatedFrames[id] = cell.frameInWindow
      return VisibleStateDetectorItem(id: String(id), target: cell, ratio: 1)
    }
    let sut = ImpressionEventTracker(
      detector: VisibleStateDetector(sushiBeltTracker: SushiBeltTracker(), sushiBeltDebugger: SushiBeltDebuggerSpy()),
      application: UIApplication.self,
      cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }),
      usesInitialVisibility: false
    )
    sut.register(scrollView: collectionView, detectorItemFactory: factory,
                 trackingRect: { collectionView.convert(collectionView.bounds, to: nil) })
    var logged: [String] = []
    sut.subscribe { logged.append($0.id) }
    sut.trackManually(shouldResetCache: false)
    XCTAssertEqual(logged.sorted(), ["0", "1"])
    let previousFrame = try XCTUnwrap(evaluatedFrames[2])
    XCTAssertEqual(previousFrame.minY, 100, accuracy: 0.01)
    evaluatedFrames.removeAll()

    collectionView.frame.size.width = 300
    collectionView.setNeedsLayout()
    collectionView.layoutIfNeeded()

    let evaluatedFrame = try XCTUnwrap(evaluatedFrames[2])
    let cell = try XCTUnwrap(collectionView.cellForItem(at: IndexPath(item: 2, section: 0)))
    XCTAssertEqual(evaluatedFrame.minY, 0, accuracy: 0.01)
    XCTAssertEqual(evaluatedFrame, cell.frameInWindow)
    XCTAssertEqual(cell.frame.minX, 200, accuracy: 0.01)
    XCTAssertEqual(logged.sorted(), ["0", "1", "2"])
    XCTAssertEqual(collectionView.contentOffset, .zero)
  }

  func test_스크롤하지_않고_크기를_바꾸면_두_등록_방식에서_다시_계산해요() {
    for usesViewController in [false, true] {
      let views: [UIScrollView] = [
        UIScrollView(), UITableView(),
        UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()),
      ]
      for scrollView in views {
        let sut = makeSUT(usesInitialVisibility: true)
        let controller = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 800))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        scrollView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        controller.view.addSubview(scrollView)
        controller.view.layoutIfNeeded()
        if usesViewController {
          sut.register(viewController: controller, scrollView: scrollView,
                       detectorItemFactory: DetectorItemFactoryStub(), trackingRect: { scrollView.bounds })
        } else {
          sut.register(scrollView: scrollView, detectorItemFactory: DetectorItemFactoryStub(),
                       trackingRect: { scrollView.bounds })
        }
        sut.subscribe { _ in }
        let before = detector.detectCallCount
        let clearBefore = detector.clearCallCount

        scrollView.frame.size.height = 400
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()

        XCTAssertEqual(detector.detectCallCount, before + 1, "\(type(of: scrollView)), VC: \(usesViewController)")
        XCTAssertEqual(detector.clearCallCount, clearBefore)
        window.isHidden = true
        window.rootViewController = nil
      }
    }
  }

  func test_같은_크기의_레이아웃과_스크롤은_크기_변경_계산을_추가하지_않아요() {
    let sut = makeSUT(usesInitialVisibility: false)
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let window = UIWindow(frame: scrollView.frame)
    window.addSubview(scrollView)
    sut.register(scrollView: scrollView, detectorItemFactory: DetectorItemFactoryStub(), trackingRect: { .zero })
    sut.subscribe { _ in }

    for _ in 0..<10 { scrollView.layoutSubviews() }
    scrollView.contentOffset.y = 20
    scrollView.layoutSubviews()

    XCTAssertEqual(detector.detectCallCount, 0)
  }

  func test_각_크기_변경은_동기로_계산하고_분리된_뷰는_무시해요() {
    let sut = makeSUT(usesInitialVisibility: false)
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 800))
    window.addSubview(scrollView)
    sut.register(scrollView: scrollView, detectorItemFactory: DetectorItemFactoryStub(), trackingRect: { .zero })
    sut.subscribe { _ in }

    for height in 201...220 {
      scrollView.frame.size.height = CGFloat(height)
      scrollView.layoutSubviews()
    }
    XCTAssertEqual(detector.detectCallCount, 20)

    scrollView.removeFromSuperview()
    scrollView.frame.size.height = 400
    scrollView.layoutSubviews()

    XCTAssertEqual(detector.detectCallCount, 20)
  }
}

// MARK: - Initial visibility

extension ImpressionEventTrackerTests {

  func test_trackManually_should_be_ignored_on_a_view_controller_registered_outside_a_window() {
    // given
    let sut = self.makeSUT(usesInitialVisibility: true)
    let viewController = UIViewController()
    viewController.loadViewIfNeeded()
    sut.register(
      viewController: viewController,
      scrollView: UIScrollView(),
      detectorItemFactory: DetectorItemFactoryStub(),
      trackingRect: { .zero },
    )
    sut.subscribe(callback: { _ in })

    // when
    sut.trackManually(shouldResetCache: true)

    // then
    XCTAssertEqual(self.detector.clearCallCount, 0)
    XCTAssertEqual(self.detector.detectCallCount, 0)
  }

  func test_a_screen_registered_on_viewDidLoad_should_detect_items_once_it_enters_a_window() {
    // given
    let sut = self.makeSUT(usesInitialVisibility: true)
    sut.subscribe(callback: { _ in })
    let viewController = RegisterOnViewDidLoadViewController(tracker: sut)
    let window = UIWindow(frame: .init(x: 0, y: 0, width: 390, height: 844))
    defer {
      window.isHidden = true
      window.rootViewController = nil
    }
    let detected = self.expectation(description: "detects visible items")
    detected.assertForOverFulfill = false
    self.detector.onDetect = { detected.fulfill() }

    // when
    window.rootViewController = viewController
    window.makeKeyAndVisible()

    // then
    self.wait(for: [detected], timeout: 1.0)
  }

  func test_application_activation_should_detect_items_on_a_screen_attached_to_a_window() {
    // given
    let sut = self.makeSUT(usesInitialVisibility: true)
    sut.subscribe(callback: { _ in })
    let viewController = RegisterOnViewDidLoadViewController(tracker: sut)
    let window = UIWindow(frame: .init(x: 0, y: 0, width: 390, height: 844))
    defer {
      window.isHidden = true
      window.rootViewController = nil
    }
    let attached = self.expectation(description: "detects visible items after attaching")
    attached.assertForOverFulfill = false
    self.detector.onDetect = { attached.fulfill() }
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    self.wait(for: [attached], timeout: 1.0)

    let activated = self.expectation(description: "detects visible items after activation")
    activated.assertForOverFulfill = false
    self.detector.onDetect = { activated.fulfill() }

    // when
    NotificationCenter.default.post(
      name: UIApplication.didBecomeActiveNotification,
      object: nil,
    )

    // then
    self.wait(for: [activated], timeout: 1.0)
  }

  func test_application_activation_should_be_ignored_on_a_screen_detached_from_its_window() {
    // given
    let sut = self.makeSUT(usesInitialVisibility: true)
    sut.subscribe(callback: { _ in })
    let viewController = RegisterOnViewDidLoadViewController(tracker: sut)
    let window = UIWindow(frame: .init(x: 0, y: 0, width: 390, height: 844))
    defer {
      window.isHidden = true
      window.rootViewController = nil
    }
    let attached = self.expectation(description: "detects visible items after attaching")
    attached.assertForOverFulfill = false
    self.detector.onDetect = { attached.fulfill() }
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    self.wait(for: [attached], timeout: 1.0)

    let cleared = self.expectation(description: "clears the cache after detaching")
    cleared.assertForOverFulfill = false
    self.detector.onClear = { cleared.fulfill() }
    window.rootViewController = UIViewController()
    self.wait(for: [cleared], timeout: 1.0)

    let detectedAfterActivation = self.expectation(description: "does not detect after activation")
    detectedAfterActivation.isInverted = true
    self.detector.onDetect = { detectedAfterActivation.fulfill() }

    // when
    NotificationCenter.default.post(
      name: UIApplication.didBecomeActiveNotification,
      object: nil,
    )

    // then
    self.wait(for: [detectedAfterActivation], timeout: 0.5)
  }
}

// MARK: - RegisterOnViewDidLoadViewController

/// Registers the tracker from `viewDidLoad`, the way production screens do.
private final class RegisterOnViewDidLoadViewController: UIViewController {

  private let tracker: ImpressionEventTracker
  private let scrollView: UIScrollView = .init()

  init(tracker: ImpressionEventTracker) {
    self.tracker = tracker
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.scrollView.frame = self.view.bounds
    self.view.addSubview(self.scrollView)
    self.tracker.register(
      viewController: self,
      scrollView: self.scrollView,
      detectorItemFactory: DetectorItemFactoryStub(),
      trackingRect: { [weak self] in
        guard let self else { return .zero }
        return self.scrollView.convert(self.scrollView.bounds, to: nil)
      },
    )
  }
}
