import XCTest
@testable import SushiBelt

final class SushiBeltTrackerTests: XCTestCase {
  
  private var scrollView: UIScrollViewStub!
  private var sushiBeltTrackerDataSource: SushiBeltTrackerDataSourceStub!
  private var sushiBeltTrackerDelegate: SushiBeltTrackerDelegateSpy!
  
  override func setUp() {
    super.setUp()
    self.scrollView = UIScrollViewStub()
    self.sushiBeltTrackerDataSource = SushiBeltTrackerDataSourceStub()
    self.sushiBeltTrackerDelegate = SushiBeltTrackerDelegateSpy()
  }
  
  private func createTracker() -> SushiBeltTracker {
    return SushiBeltTracker(
      scrollView: self.scrollView,
      dataSource: self.sushiBeltTrackerDataSource,
      delegate: self.sushiBeltTrackerDelegate
    )
  }
}
