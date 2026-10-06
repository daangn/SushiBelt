import UIKit

enum TrackingEvent {
  case entered
  case exited
  case ended
  case evaluated
  case clearing
}

protocol TrackingItem: AnyObject, SushiBeltTrackerIdentifier {
  var target: ImpressionDetectorTarget { get }
  var ratio: CGFloat { get }
  var tracksExit: Bool { get }
  var isValid: Bool { get }

  func receive(_ event: TrackingEvent, delegate: VisibleStateDetectorDelegate?)
}

extension TrackingItem {
  func makeTrackerItem(viewport: CGRect) -> SushiBeltTrackerItem? {
    guard isValid else { return nil }
    let frame = target.frameInWindow
    guard viewport.intersection(frame).height > 0 else { return nil }
    return SushiBeltTrackerItem(
      id: .trackingIdentifier(self),
      rect: .init(frame: frame),
      tracksExit: tracksExit
    )
  }
}
