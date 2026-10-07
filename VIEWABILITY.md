# UIKit viewability events

Unreleased API. A single tracker delivers normal impressions and continuous
viewability transitions independently. Duration thresholds, item business IDs,
session storage, and event delivery belong to the caller.

## Declare both thresholds

```swift
let impressionItem = VisibleStateDetectorItem(
  id: itemID,
  target: cell,
  ratio: 0.1
)
let viewabilityItem = ViewabilityItem(
  id: itemID,
  target: cell,
  ratio: 0.5
)
```

Each item uses its own `ratio`. `VisibleStateDetectorItem` registers ordinary
impressions; `ViewabilityItem` registers continuous enter/exit events. Viewability
ratios must be finite values in `0...1`. IDs must be unique within each registration
type; the same ID can independently register an impression and viewability target.
Duplicate IDs within one list use the first registration.

```swift
let factory = DefaultDetectorItemFactory(
  mapper: { cell in
    VisibleStateDetectorItem(id: itemID(for: cell), target: cell, ratio: 0.1)
  },
  viewabilityMapper: { cell in
    ViewabilityItem(id: itemID(for: cell), target: cell, ratio: 0.5)
  }
)
```

The existing single-item `mapper:` initializer remains available. Custom
`DetectorItemFactory` implementations can supply `makeViewabilityItems(view:)`;
its default implementation returns an empty list. Nested scroll tracking and
clearing are forwarded only by impression registrations.

## Subscribe independently

```swift
tracker.subscribe { item in
  // Normal impression, after the existing filter and cooldown.
}

tracker.subscribeViewability { event in
  switch event {
  case .entered(let item):
    // Save the start time and immutable application payload.
  case .exited(let item):
    // Remove the matching session and evaluate its duration.
  }
}
```

- Viewability bypasses the impression filter and cooldown.
- Viewability-only subscriptions are supported.
- Exits occur below the threshold, on removal, and on `clearCache()`.
- The exit carries the item captured at entry, not the current reused cell data.
- Registering with a view controller also clears tracking when that controller
  disappears or the application resigns active. The scroll-view-only overload
  leaves lifecycle forwarding to its owner.
- Callbacks are synchronous with detection. Perform registration and tracking
  operations on the main thread. Do not mutate the tracker from its callbacks.

## Replace a list

```swift
tracker.clearCache()  // Emits exits for active sessions before replacing data.

applySnapshot {
  tracker.trackManually(shouldResetCache: false)
}
```

For an append, omit `clearCache()` to preserve existing sessions.

## Compatibility

Existing `subscribe` calls, impression item initializers, and impression-only
factories keep their behavior. The unreleased `kind` and `itemsMapper:` APIs are
replaced by typed registrations and separate factory mappers. Custom
`ImpressionEventTrackable` implementations and generated mocks must implement
the new `subscribeViewability` requirement. SwiftUI APIs are unchanged.
