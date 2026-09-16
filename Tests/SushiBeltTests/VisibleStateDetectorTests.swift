import UIKit
import XCTest

@testable import KarrotImpression

final class VisibleStateDetectorTests: XCTestCase {

  func test_excludes_empty_intersections_at_zero_threshold() {
    let frames: [CGRect] = [
      CGRect(x: 100, y: 0, width: 100, height: 100),
      CGRect(x: 0, y: 100, width: 100, height: 100),
      CGRect(x: 101, y: 0, width: 100, height: 100),
      CGRect(x: 0, y: 101, width: 100, height: 100),
      CGRect(x: 50, y: 0, width: 0, height: 100),
      CGRect(x: 0, y: 50, width: 100, height: 0),
    ]

    for frame in frames {
      let tracker = SushiBeltTracker()
      let detector = VisibleStateDetector(
        sushiBeltTracker: tracker,
        sushiBeltDebugger: SushiBeltDebuggerSpy()
      )
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
      let target = UIView(frame: frame)
      window.addSubview(target)
      let item = VisibleStateDetectorItem(id: "item", target: target, ratio: 0)

      detector.detect(items: [item], trackingRect: { CGRect(x: 0, y: 0, width: 100, height: 100) })

      XCTAssertTrue(tracker.cachedItems.isEmpty, "Unexpected candidate: \(frame)")
    }
  }

  func test_tracks_positive_intersection_at_zero_threshold() {
    let tracker = SushiBeltTracker()
    let detector = VisibleStateDetector(
      sushiBeltTracker: tracker,
      sushiBeltDebugger: SushiBeltDebuggerSpy()
    )
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    let target = UIView(frame: CGRect(x: 99, y: 0, width: 100, height: 100))
    window.addSubview(target)
    let item = VisibleStateDetectorItem(id: "item", target: target, ratio: 0)

    detector.detect(items: [item], trackingRect: { CGRect(x: 0, y: 0, width: 100, height: 100) })

    XCTAssertEqual(tracker.cachedItems.count, 1)
    XCTAssertEqual(tracker.cachedItems.first?.isTracked, true)
  }
}
