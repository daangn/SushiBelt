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
