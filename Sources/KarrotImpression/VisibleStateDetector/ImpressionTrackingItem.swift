import UIKit

final class ImpressionTrackingItem: TrackingItem {
  let trackingIdentifer: String
  var registration: VisibleStateDetectorItem
  private weak var handler: ImpressionHandler?
  var target: ImpressionDetectorTarget { registration.target }
  var ratio: CGFloat { registration.ratio }
  let tracksExit = false
  let isValid = true

  init(item: VisibleStateDetectorItem, handler: ImpressionHandler) {
    trackingIdentifer = "impression:\(item.id)"
    registration = item
    self.handler = handler
  }

  func receive(_ event: TrackingEvent, delegate: VisibleStateDetectorDelegate?) {
    let nestedTarget = registration.target as? ImpressionInnerScrollable
    switch event {
    case .entered:
      delegate?.onDetect(visibleItem: registration)
      nestedTarget?.trackImpressionEvent()
    case .evaluated:
      nestedTarget?.trackImpressionEvent()
    case .ended:
      guard handler?.contains(self) == true else { return }
      nestedTarget?.clearImpressionEvent()
    case .clearing:
      nestedTarget?.clearImpressionEvent()
    case .exited:
      break
    }
  }
}
