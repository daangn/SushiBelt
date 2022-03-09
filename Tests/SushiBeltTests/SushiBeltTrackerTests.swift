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
  
  private func createTracker() -> SushiBeltTracker {
    let tracker = SushiBeltTracker()
    tracker.scrollView = self.scrollView
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
    let direction = tracker.scrollDrection()
    
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
    let direction = tracker.scrollDrection()
    
    // then
    XCTAssertEqual(direction, .right)
  }

  func test_scrollDirection_should_return_up() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 0.0, y: -100.0)
    
    // when
    let direction = tracker.scrollDrection()
    
    // then
    XCTAssertEqual(direction, .up)
  }
  
  func test_scrollDirection_should_return_down() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 0.0, y: 100.0)
    
    // when
    let direction = tracker.scrollDrection()
    
    // then
    XCTAssertEqual(direction, .down)
  }
  
  func test_scrollDirection_should_return_left() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 100.0, y: 0.0)
    
    // when
    let direction = tracker.scrollDrection()
    
    // then
    XCTAssertEqual(direction, .left)
  }
  
  func test_scrollDirection_should_return_right() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: -100.0, y: 0.0)
    
    // when
    let direction = tracker.scrollDrection()
    
    // then
    XCTAssertEqual(direction, .right)
  }
  
  func test_scrollDirection_not_support_diagonal_direction() {
    // given
    let tracker = self.createTracker()
    self.scrollView.panGestureRecognizerStub = self.panGestureRecognizer
    self.panGestureRecognizer.velocityStub = .init(x: 100.0, y: 100.0)
    
    // when
    let direction = tracker.scrollDrection()
    
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
          view: UIView(frame: .zero)
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
          view: UIView(frame: .zero)
        )
      ]
    )
    
    // then
    XCTAssertNil(self.debugger.updateItems)
    XCTAssertNil(self.debugger.updateScrollDirection)
  }
}
