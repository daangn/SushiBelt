import Testing
import UIKit

@testable import KarrotImpression

@MainActor
struct VisibleStateDetectorGeometryTests {
  private struct FrameTarget: ImpressionDetectorTarget {
    let frameInWindow: CGRect
  }

  private func makeSUT() -> (VisibleStateDetector, ImpressionEventTracker) {
    let detector = VisibleStateDetector(
      sushiBeltTracker: SushiBeltTracker(),
      sushiBeltDebugger: SushiBeltDebuggerSpy()
    )
    let tracker = ImpressionEventTracker(
      detector: detector,
      application: UIApplication.self,
      cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }),
      usesInitialVisibility: false
    )
    return (detector, tracker)
  }

  @Test(arguments: [
    CGRect(x: 100, y: 0, width: 100, height: 100),
    CGRect(x: 0, y: 100, width: 100, height: 100),
    CGRect(x: 100, y: 100, width: 100, height: 100),
    CGRect(x: 200, y: 0, width: 100, height: 100),
    CGRect(x: 99, y: 0, width: 100, height: 100),
    CGRect(x: 0, y: 99, width: 100, height: 100),
  ])
  func test_zero_ratio_impressions_should_require_positive_intersection_width_and_height(frame: CGRect) {
    let (detector, tracker) = makeSUT()
    let viewport = CGRect(x: 0, y: 0, width: 100, height: 100)
    let intersection = viewport.intersection(frame)
    let isVisible = intersection.width > 0 && intersection.height > 0
    var impressions: [String] = []
    tracker.subscribe { impressions.append($0.id) }

    detector.detect(items: [
      .init(id: "item", target: FrameTarget(frameInWindow: frame), ratio: 0)
    ]) { viewport }

    #expect(impressions == (isVisible ? ["item"] : []))
  }
}
