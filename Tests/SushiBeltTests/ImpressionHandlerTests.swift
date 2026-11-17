import Testing
import UIKit

@testable import KarrotImpression

@MainActor
struct ImpressionHandlerTests {
  private struct FrameTarget: ImpressionDetectorTarget {
    let frameInWindow: CGRect
  }

  private final class NestedTarget: ImpressionDetectorTarget, ImpressionInnerScrollable {
    var frameInWindow = CGRect(x: 0, y: 0, width: 100, height: 100)
    var operations: [String] = []
    func trackImpressionEvent() { operations.append("track") }
    func clearImpressionEvent() { operations.append("clear") }
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
    tracker.subscribe { _ in }
    return (detector, tracker)
  }

  @Test
  func test_item_clip_and_viewport_determine_entry_and_full_exit_for_the_same_id() {
    let (detector, tracker) = makeSUT()
    let target = FrameTarget(frameInWindow: CGRect(x: 0, y: 0, width: 100, height: 100))
    let viewport = CGRect(x: 20, y: 0, width: 80, height: 100)
    var impressions = 0
    tracker.subscribe { _ in impressions += 1 }

    // The viewport hides the first 20 points of the card.
    func detect(clipWidth: CGFloat) {
      let clip = CGRect(x: 0, y: 0, width: clipWidth, height: 100)
      let item = VisibleStateDetectorItem(id: "card", target: target, ratio: 0.5, trackingRectInWindow: clip)
      detector.detect(items: [item]) { viewport }
    }

    detect(clipWidth: 69)
    #expect(impressions == 0)
    detect(clipWidth: 70)
    #expect(impressions == 1)
    detect(clipWidth: 69)
    detect(clipWidth: 70)
    #expect(impressions == 1)
    detect(clipWidth: 20)
    detect(clipWidth: 70)
    #expect(impressions == 2)
  }

  @Test
  func test_zero_threshold_requires_positive_area_inside_the_clip_and_only_limits_that_item() {
    let (detector, tracker) = makeSUT()
    let viewport = CGRect(x: 0, y: 0, width: 200, height: 100)
    let target = FrameTarget(frameInWindow: CGRect(x: 100, y: 0, width: 100, height: 100))
    var ids: [String] = []
    tracker.subscribe { ids.append($0.id) }

    func detect(clipWidth: CGFloat) {
      let clip = CGRect(x: 0, y: 0, width: clipWidth, height: 100)
      let clipped = VisibleStateDetectorItem(id: "clipped", target: target, ratio: 0, trackingRectInWindow: clip)
      let neighbor = VisibleStateDetectorItem(id: "neighbor", target: target, ratio: 0)
      detector.detect(items: [clipped, neighbor]) { viewport }
    }

    detect(clipWidth: 99)
    detect(clipWidth: 100)
    #expect(ids == ["neighbor"])
    detect(clipWidth: 101)
    #expect(ids == ["neighbor", "clipped"])
  }

  @Test
  func test_removing_an_impression_should_preserve_the_existing_nested_scroll_lifecycle() {
    let (detector, tracker) = makeSUT()
    let target = NestedTarget()
    let item = VisibleStateDetectorItem(id: "item", target: target, ratio: 0.1)
    let viewport = CGRect(x: 0, y: 0, width: 100, height: 100)

    detector.detect(items: [item]) { viewport }
    detector.detect(items: []) { viewport }
    tracker.clearCache()

    #expect(target.operations == ["track", "track"])
  }

  @Test
  func test_an_offscreen_registered_impression_should_clear_then_update_its_nested_scroll() {
    let (detector, _) = makeSUT()
    let target = NestedTarget()
    let item = VisibleStateDetectorItem(id: "item", target: target, ratio: 0.1)
    let viewport = CGRect(x: 0, y: 0, width: 100, height: 100)
    detector.detect(items: [item]) { viewport }

    target.frameInWindow.origin.y = 200
    detector.detect(items: [item]) { viewport }

    #expect(target.operations == ["track", "track", "clear", "track"])
  }

  @Test
  func test_clear_should_forward_one_nested_clear_without_repeating_it_on_tracking_end() {
    let (detector, tracker) = makeSUT()
    let target = NestedTarget()
    let item = VisibleStateDetectorItem(id: "item", target: target, ratio: 0.1)
    detector.detect(items: [item]) { CGRect(x: 0, y: 0, width: 100, height: 100) }

    tracker.clearCache()
    tracker.clearCache()

    #expect(target.operations == ["track", "track", "clear"])
  }

  @Test
  func test_an_existing_registration_should_use_the_latest_threshold_and_payload_before_entry() {
    let (detector, tracker) = makeSUT()
    let target = NestedTarget()
    let original = VisibleStateDetectorItem(
      id: "item", target: target, ratio: 1, userInfo: ["marker": "original"]
    )
    let updated = VisibleStateDetectorItem(
      id: "item", target: target, ratio: 0.1, userInfo: ["marker": "updated"]
    )
    var markers: [String] = []
    tracker.subscribe { markers.append($0.userInfo?["marker"] as? String ?? "missing") }
    let viewport = CGRect(x: 0, y: 0, width: 100, height: 50)

    detector.detect(items: [original]) { viewport }
    detector.detect(items: [updated]) { viewport }

    #expect(markers == ["updated"])
  }
}
