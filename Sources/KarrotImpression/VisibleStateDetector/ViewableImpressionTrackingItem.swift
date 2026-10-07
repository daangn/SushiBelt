import UIKit

final class ViewableImpressionTrackingItem: TrackingItem {
  let trackingIdentifer: String
  var registration: ViewabilityItem
  private weak var handler: ViewableImpressionHandler?
  var target: ImpressionDetectorTarget { registration.target }
  var ratio: CGFloat { registration.ratio }
  let tracksExit = true

  var isValid: Bool {
    return ratio.isFinite && (0...1).contains(ratio)
  }

  init(item: ViewabilityItem, handler: ViewableImpressionHandler) {
    trackingIdentifer = "viewability:\(item.id)"
    registration = item
    self.handler = handler
  }

  func receive(_ event: TrackingEvent, delegate: VisibleStateDetectorDelegate?) {
    switch event {
    case .entered:
      handler?.enter(registration: registration, delegate: delegate)
    case .exited:
      handler?.exit(id: registration.id, delegate: delegate)
    case .ended, .evaluated, .clearing:
      break
    }
  }
}
