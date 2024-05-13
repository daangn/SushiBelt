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
    tracker.scrollContext = SushiBeltTrackerUIScrollContext(scrollView: self.scrollView)
    tracker.delegate = self.sushiBeltTrackerDelegate
    tracker.dataSource = self.sushiBeltTrackerDataSource
    return tracker
  }
}

// MARK: - scroll direction

extension SushiBeltTrackerTests {
  
  func test_scrollDirection_should_return_default_scroll_direction_on_zero_velocity() {
    // given
    let tracker = self.createTracker()
    tracker.defaultScrollDirection = .left
    
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .zero
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertEqual(direction, .left)
  }
  
  func test_scrollDirection_should_return_recent_scroll_direction_on_zero_velocity() {
    // given
    let tracker = self.createTracker()
    tracker.defaultScrollDirection = .left
    tracker.recentScrollDirection = .right
    
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .zero
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertEqual(direction, .right)
  }

  func test_scrollDirection_should_return_up() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 0.0, y: -100.0)
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertEqual(direction, .up)
  }
  
  func test_scrollDirection_should_return_down() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 0.0, y: 100.0)
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertEqual(direction, .down)
  }
  
  func test_scrollDirection_should_return_left() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 100.0, y: 0.0)
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertEqual(direction, .left)
  }
  
  func test_scrollDirection_should_return_right() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: -100.0, y: 0.0)
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertEqual(direction, .right)
  }
  
  func test_scrollDirection_not_support_diagonal_direction() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 100.0, y: 100.0)
    
    // when
    let direction = tracker.scrollDirection()
    
    // then
    XCTAssertNil(direction)
  }
}

// MARK: - debug

extension SushiBeltTrackerTests {
  
  func test_calculateItemsIfNeeded_should_call_debugger_on_debugger_registerd() {
    // given
    let tracker = self.createTracker()
    tracker.recentScrollDirection = .down
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
    XCTAssertEqual(self.debugger.updateScrollDirection, .down)
  }
  
  func test_calculateItemsIfNeeded_should_not_call_debugger_on_debugger_unregisterd() {
    // given
    let tracker = self.createTracker()
    tracker.recentScrollDirection = .down
    
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
    XCTAssertNil(self.debugger.updateScrollDirection)
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
