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
  var trackingRectInWindow: CGRect? { get }
  var tracksExit: Bool { get }
  var isValid: Bool { get }

  func receive(_ event: TrackingEvent, delegate: VisibleStateDetectorDelegate?)
}

extension TrackingItem {
  var trackingRectInWindow: CGRect? { nil }

  func makeTrackerItem(viewport: CGRect) -> SushiBeltTrackerItem? {
    guard isValid else { return nil }
    let rect = SushiBeltTrackerItemRect(frame: target.frameInWindow, trackingRectInWindow: trackingRectInWindow)
    let visibleRect = rect.visibleRect(in: viewport)
    if rect.trackingRectInWindow != nil {
      guard !visibleRect.isEmpty else { return nil }
    } else {
      guard visibleRect.height > 0 else { return nil }
    }
    return SushiBeltTrackerItem(
      id: .trackingIdentifier(self),
      rect: rect,
      tracksExit: tracksExit
    )
  }
}
