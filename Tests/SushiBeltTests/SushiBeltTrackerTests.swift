import XCTest
@testable import SushiBelt

final class SushiBeltTrackerTests: XCTestCase {
  
  private var scrollView: UIScrollViewStub!
  private var panGestureRecognizer: UIPanGestureRecognizerStub!
  private var sushiBeltTrackerDataSource: SushiBeltTrackerDataSourceStub!
  private var sushiBeltTrackerDelegate: SushiBeltTrackerDelegateSpy!
  private var debugger: SushiBeltDebuggerSpy!
  
  override func setUp() {
    super.setUp()
    self.scrollView = UIScrollViewStub()
    self.panGestureRecognizer = UIPanGestureRecognizerStub()
    self.sushiBeltTrackerDataSource = SushiBeltTrackerDataSourceStub()
    self.sushiBeltTrackerDelegate = SushiBeltTrackerDelegateSpy()
    self.debugger = SushiBeltDebuggerSpy()
  }
  
  private func createTracker(
    visibleRatioCalculator: VisibleRatioCalculator? = nil,
    trackerItemDiffChecker: SushiBeltTrackerItemDiffChecker? = nil
  ) -> SushiBeltTracker {
    let tracker = SushiBeltTracker(
      visibleRatioCalculator: visibleRatioCalculator,
      trackerItemDiffChecker: trackerItemDiffChecker
    )
    tracker.delegate = self.sushiBeltTrackerDelegate
    tracker.dataSource = self.sushiBeltTrackerDataSource
    return tracker
  }
}


// MARK: - debug

extension SushiBeltTrackerTests {
  
  func test_calculateItemsIfNeeded_should_call_debugger_on_debugger_registerd() {
    // given
    let tracker = self.createTracker()
    tracker.registerDebugger(debugger: self.debugger)
    
    // when
    tracker.calculateItemsIfNeeded(
      items: [
        SushiBeltTrackerItem(
          id: .index(1),
          rect: .init(frame: .zero)
        )
      ]
    )
    
    // then
    XCTAssertEqual(self.debugger.updateItems?.count, 1)
  }
  
  func test_calculateItemsIfNeeded_should_not_call_debugger_on_debugger_unregisterd() {
    // given
    let tracker = self.createTracker()
    
    // when
    tracker.calculateItemsIfNeeded(
      items: [
        SushiBeltTrackerItem(
          id: .index(1),
          rect: .init(frame: .zero)
        )
      ]
    )
    
    // then
    XCTAssertNil(self.debugger.updateItems)
  }
}

// MARK: - tracked

extension SushiBeltTrackerTests {
  
  func test_checkBeginTrackingItems_check_tracked_items() {
    // given
    let tracker = self.createTracker()
    let items = [
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: -100.0, width: 100.0, height: 100.0)),
      SushiBeltTrackerItem(
        id: .index(2),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)),
      SushiBeltTrackerItem(
        id: .index(3),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: 100.0, width: 100.0, height: 100.0))
    ]
    
    tracker.cachedItems = .init(items)
    
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(
      x: 0.0,
      y: 0.0,
      width: 100.0,
      height: 100.0
    )
    
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5
    
    // when
    tracker.checkBeginTrackingItems(items: .init(items))
    
    // then
    let trackedItems = tracker.cachedItems.filter({ $0.isTracked })
    XCTAssertEqual(trackedItems.count, 1)
  }
  
  func test_checkBeginTrackingItems_should_call_didTrack() {
    // given
    let tracker = self.createTracker()
    let items = [
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: -100.0, width: 100.0, height: 100.0)),
      SushiBeltTrackerItem(
        id: .index(2),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: -20.0, width: 100.0, height: 100.0)),
      SushiBeltTrackerItem(
        id: .index(3),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: 100.0, width: 100.0, height: 100.0))
    ]
    
    tracker.cachedItems = .init(items)
    
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(
      x: 0.0,
      y: 0.0,
      width: 100.0,
      height: 100.0
    )
    
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5
    
    // when
    tracker.checkBeginTrackingItems(items: .init(items))
    
    // then
    let trackedItems = tracker.cachedItems.filter({ $0.isTracked })
    XCTAssertEqual(trackedItems.count, 1)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.count, 1)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.first?.currentVisibleRatio, 0.8)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.first?.objectiveVisibleRatio, 0.5)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.first?.isTracked, true)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.first?.id, .index(2))
  }
  
  func test_checkBeginTrackingItems_should_not_call_didTrack_on_already_tracked() {
    // given
    let tracker = self.createTracker()
    let items = [
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: -100.0, width: 100.0, height: 100.0)),
      SushiBeltTrackerItem(
        id: .index(2),
        rect: .init(frame: .zero)
      ).tracked().frameInWindow(CGRect(x: 0.0, y: -20.0, width: 100.0, height: 100.0)),
      SushiBeltTrackerItem(
        id: .index(3),
        rect: .init(frame: .zero)
      ).frameInWindow(CGRect(x: 0.0, y: 100.0, width: 100.0, height: 100.0))
    ]
    
    tracker.cachedItems = .init(items)
    
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(
      x: 0.0,
      y: 0.0,
      width: 100.0,
      height: 100.0
    )
    
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5
    
    // when
    tracker.checkBeginTrackingItems(items: .init(items))
    
    // then
    let trackedItems = tracker.cachedItems.filter({ $0.isTracked })
    XCTAssertEqual(trackedItems.count, 1)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.isEmpty, true)
  }
}

// MARK: - willBeginTracking

extension SushiBeltTrackerTests {

  func test_checkBeginTrackingItems_willBeginTracking() {
    // given
    let tracker = self.createTracker()
    let items = [
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(x: 0.0, y: 100.0, width: 100.0, height: 100.0)
      )
    ]

    tracker.cachedItems = .init()

    // when
    tracker.calculateItemsIfNeeded(items: items)

    // then
    XCTAssertEqual(self.sushiBeltTrackerDelegate.willBeginTrackingItems.count, 1)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didEndTrackingItems.count, 0)
  }
}


// MARK: - didEndTracking

extension SushiBeltTrackerTests {

  func test_checkBeginTrackingItems_didEndTracking() {
    // given
    let tracker = self.createTracker()
    let items: [SushiBeltTrackerItem] = []

    tracker.cachedItems = .init([
      SushiBeltTrackerItem(
        id: .index(1),
        rect: .init(x: 0.0, y: 100.0, width: 100.0, height: 100.0)
      )
    ])

    // when
    tracker.calculateItemsIfNeeded(items: items)

    // then
    XCTAssertEqual(self.sushiBeltTrackerDelegate.willBeginTrackingItems.count, 0)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didEndTrackingItems.count, 1)
  }
}

// MARK: - tracksDismiss (symmetric tracking)

extension SushiBeltTrackerTests {

  /// Sticky items (tracksDismiss == false) keep the early-exit path even when
  /// the live ratio drops below the threshold. didDismiss must never fire and
  /// isTracked must stay true.
  func test_sticky_no_didDismiss_after_down_cross() {
    // given — tracked sticky item, now positioned below threshold
    let tracker = self.createTracker()
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5

    let item = SushiBeltTrackerItem(
      id: .index(1),
      rect: .init(frame: .zero)
    )
      .tracked()
      .frameInWindow(.init(x: 0.0, y: 80.0, width: 100.0, height: 100.0))  // ratio 0.2 < 0.5

    tracker.cachedItems = .init([item])

    // when
    tracker.checkBeginTrackingItems(items: .init([item]))

    // then
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.count, 0)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didDismissItems.count, 0)
    XCTAssertEqual(tracker.cachedItems.first?.isTracked, true)
  }

  /// Symmetric item crosses the threshold up → didTrack fires and isTracked
  /// is set to true. Mirrors the sticky up-cross path.
  func test_symmetric_didTrack_on_up_cross() {
    // given
    let tracker = self.createTracker()
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5

    let item = SushiBeltTrackerItem(
      id: .index(1),
      rect: .init(frame: .zero),
      tracksDismiss: true
    ).frameInWindow(.init(x: 0.0, y: 0.0, width: 100.0, height: 100.0))   // ratio 1.0

    tracker.cachedItems = .init([item])

    // when
    tracker.checkBeginTrackingItems(items: .init([item]))

    // then
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.count, 1)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didDismissItems.count, 0)
    XCTAssertEqual(tracker.cachedItems.first?.isTracked, true)
  }

  /// Tracked symmetric item drops below threshold while still in the set →
  /// didDismiss fires and isTracked flips back to false.
  func test_symmetric_didDismiss_on_down_cross_while_in_set() {
    // given — tracked symmetric item, ratio now below threshold
    let tracker = self.createTracker()
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5

    let item = SushiBeltTrackerItem(
      id: .index(1),
      rect: .init(frame: .zero),
      tracksDismiss: true
    )
      .tracked()
      .frameInWindow(.init(x: 0.0, y: 80.0, width: 100.0, height: 100.0))  // ratio 0.2 < 0.5

    tracker.cachedItems = .init([item])

    // when
    tracker.checkBeginTrackingItems(items: .init([item]))

    // then
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.count, 0)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didDismissItems.count, 1)
    XCTAssertEqual(tracker.cachedItems.first?.isTracked, false)
  }

  /// Symmetric item that dipped below threshold (didDismiss fired) must
  /// receive didTrack again when it returns above threshold — verifying that
  /// isTracked is truly live (not sticky) under tracksDismiss == true.
  func test_symmetric_didTrack_fires_again_on_reentry() {
    // given
    let tracker = self.createTracker()
    self.sushiBeltTrackerDataSource.trackingRectStub = .init(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
    self.sushiBeltTrackerDataSource.visibleRatioForItemStub = 0.5

    let aboveFrame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)   // ratio 1.0
    let belowFrame = CGRect(x: 0.0, y: 80.0, width: 100.0, height: 100.0)  // ratio 0.2

    let baseItem = SushiBeltTrackerItem(
      id: .index(1),
      rect: .init(frame: .zero),
      tracksDismiss: true
    )

    // tick 1 — above threshold → didTrack
    let tick1 = baseItem.frameInWindow(aboveFrame)
    tracker.cachedItems = .init([tick1])
    tracker.checkBeginTrackingItems(items: .init([tick1]))

    // tick 2 — dropped below threshold → didDismiss
    let tick2 = tracker.cachedItems.first!.frameInWindow(belowFrame)
    tracker.cachedItems = .init([tick2])
    tracker.checkBeginTrackingItems(items: .init([tick2]))

    // tick 3 — back above threshold → didTrack again
    let tick3 = tracker.cachedItems.first!.frameInWindow(aboveFrame)
    tracker.cachedItems = .init([tick3])
    tracker.checkBeginTrackingItems(items: .init([tick3]))

    // then
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didTrackItems.count, 2)
    XCTAssertEqual(self.sushiBeltTrackerDelegate.didDismissItems.count, 1)
    XCTAssertEqual(tracker.cachedItems.first?.isTracked, true)
  }
}
