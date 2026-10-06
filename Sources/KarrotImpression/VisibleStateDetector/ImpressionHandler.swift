import UIKit

final class ImpressionHandler {
  private var registrations: [String: ImpressionTrackingItem] = [:]

  func update(items: [VisibleStateDetectorItem]) {
    var next: [String: ImpressionTrackingItem] = [:]
    for registration in items where next[registration.id] == nil {
      let trackingItem = registrations[registration.id]
        ?? ImpressionTrackingItem(item: registration, handler: self)
      trackingItem.registration = registration
      next[registration.id] = trackingItem
    }
    registrations = next
  }

  func contains(_ trackingItem: ImpressionTrackingItem) -> Bool {
    registrations[trackingItem.registration.id] === trackingItem
  }

  func makeTrackerItems(viewport: CGRect) -> [SushiBeltTrackerItem] {
    registrations.values.compactMap { $0.makeTrackerItem(viewport: viewport) }
  }

  func evaluate(delegate: VisibleStateDetectorDelegate?) {
    for trackingItem in registrations.values {
      trackingItem.receive(.evaluated, delegate: delegate)
    }
  }

  func clear(delegate: VisibleStateDetectorDelegate?) {
    for trackingItem in registrations.values {
      trackingItem.receive(.clearing, delegate: delegate)
    }
    registrations.removeAll()
  }
}
