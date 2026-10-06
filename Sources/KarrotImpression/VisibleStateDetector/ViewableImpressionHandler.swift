import UIKit

final class ViewableImpressionHandler {
  private var registrations: [String: ViewableImpressionTrackingItem] = [:]
  private var activeSessions: [String: ViewabilityItem] = [:]

  func update(items: [ViewabilityItem]) {
    var next: [String: ViewableImpressionTrackingItem] = [:]
    for registration in items where next[registration.id] == nil {
      let trackingItem = registrations[registration.id]
        ?? ViewableImpressionTrackingItem(item: registration, handler: self)
      trackingItem.registration = registration
      next[registration.id] = trackingItem
    }
    registrations = next
  }

  func makeTrackerItems(viewport: CGRect) -> [SushiBeltTrackerItem] {
    registrations.values.compactMap { $0.makeTrackerItem(viewport: viewport) }
  }

  func enter(registration: ViewabilityItem, delegate: VisibleStateDetectorDelegate?) {
    guard activeSessions[registration.id] == nil else { return }
    activeSessions[registration.id] = registration
    delegate?.onViewabilityChanged(.entered(registration))
  }

  func exit(id: String, delegate: VisibleStateDetectorDelegate?) {
    guard let enteredRegistration = activeSessions.removeValue(forKey: id) else { return }
    delegate?.onViewabilityChanged(.exited(enteredRegistration))
  }

  func clear() {
    // The engine delivers exits for active sessions when its tracked set is cleared.
    registrations.removeAll()
  }
}
