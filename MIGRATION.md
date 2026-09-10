# Migration Guide

## SushiBelt → KarrotImpression (unreleased)

The repository name remains `SushiBelt`, but the package, library product, and
import name are `KarrotImpression`. Existing SushiBelt tags and the CocoaPods
spec do not contain this API. See the [README](README.md#installation) for trying
the unreleased package locally.

This update replaces the public low-level tracker API rather than aliasing it:

| Previous API | KarrotImpression |
| --- | --- |
| `import SushiBelt` | Link the `KarrotImpression` product and use `import KarrotImpression`. |
| `SushiBeltTracker()` | Create a UIKit tracker with `ImpressionEventTrackerBuilder().build()`. |
| Tracker data source and item identifiers | Supply a `DetectorItemFactory` that returns `VisibleStateDetectorItem` values with stable string IDs. |
| `trackingRect(_:)` | Pass a window-coordinate rectangle provider to `register`. |
| `visibleRatioForItem(_:item:)` | Set `VisibleStateDetectorItem.ratio`. |
| `didEnter(_:item:)` | Receive UIKit entries with `tracker.subscribe(callback:)`. |
| `didExit`, `willBeginTracking`, `didEndTracking` | No equivalent public UIKit callbacks. SwiftUI offers opt-in entry/exit callbacks through `tracksExit`. |
| Custom engine diff checker or ratio calculator | No public injection point; these types are internal. |

Register the UIKit tracker once per scroll view and retain it for the scroll
view's lifetime. The overload with a view controller observes screen and app
lifecycle events. The overload without one is intended for nested scroll views
and requires the owner to forward lifecycle-related tracking and clearing requests.

Check these behaviors when migrating:

- Both the target frame and tracking rectangle must use window coordinates.
- The default factory maps visible table/collection cells only. Use a custom
  factory for supplementary views or other scroll-view content.
- `clearCache()` resets tracked-item state, not cooldowns. Keep the injected
  `ImpressionCooltimeCache` if you need to clear or share cooldown state explicitly.
- SwiftUI policies have their own storage; they do not share UIKit cooldowns.
- The existing `Example/` CocoaPods project uses the previous API and is not
  updated by changing its import.

See the [UIKit](README.md#uikit) and [SwiftUI](README.md#swiftui) examples for the
current call shapes. Validate callback timing and repeat-impression rules in
your own screens; the new API is not a source-compatible delegate replacement.

## 2.x → 3.0

This section applies only to the previous public SushiBelt API, not to the
KarrotImpression package above.

SushiBelt 3.0 introduces **symmetric threshold tracking** (an opt-in
`didExit` down-crossing callback) and, to make the delegate API symmetric,
renames the existing up-crossing callback `didTrack` to `didEnter`.

The rename is the **only** breaking change. Everything else in 3.0 is additive
and requires no action unless you opt in.

### What changed

| 2.x | 3.0 | Kind |
|---|---|---|
| `func didTrack(_:item:)` | `func didEnter(_:item:)` | **Breaking** — renamed |
| — | `func didExit(_:item:)` | Additive — optional (default no-op) |
| — | `SushiBeltTrackerItem(…, tracksExit:)` | Additive — new init parameter, defaults to `false` |

### Why `didTrack` was renamed

The new callback fires when an item's visible ratio crosses **down** below the
threshold while the item is still in the tracked set. Naming it as the opposite
of `didTrack` was awkward — `track` has no natural antonym, and candidates like
`dismiss`/`exit` collided with unrelated concepts (`UIViewController.dismiss`,
the set-membership callback `didEndTracking`).

SushiBelt has two independent axes:

| Axis | Enters | Leaves |
|---|---|---|
| **Set membership** | `willBeginTracking` | `didEndTracking` |
| **Visibility threshold** | `didEnter` (was `didTrack`) | `didExit` (new) |

`didEnter` / `didExit` form a clean symmetric pair on the threshold axis, and
the `…Tracking` suffix keeps the membership callbacks visually distinct. When
`didExit` fires, the item is still in the set — only its visible ratio dropped
below the threshold (`isTracked: true → false`).

### How to migrate

Rename your delegate method. The signature and firing semantics are identical —
only the name changed:

```diff
  extension SomeObject: SushiBeltTrackerDelegate {

-   func didTrack(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
+   func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
      // unchanged body
    }
  }
```

`didEnter` is a required protocol method with no default implementation, so the
compiler flags every conformance that still defines `didTrack`. There is no
silent behavior change — build errors surface every call site.

### Nothing else required

- Existing **sticky** tracking is unchanged. Items still fire `didEnter` once on
  the first up-crossing and stay tracked until they leave the set.
- `didExit` and `tracksExit` are opt-in. You only touch them when you want
  symmetric "above/below threshold" signaling (e.g. viewable-impression
  start/end pairs, time-in-view).

### Opting into symmetric tracking (optional)

```swift
let item = SushiBeltTrackerItem(
  id: .index(0),
  rect: someRect,
  tracksExit: true
)

extension SomeObject: SushiBeltTrackerDelegate {

  func didEnter(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    // ratio crossed up — start of a visible session
  }

  func didExit(_ tracker: SushiBeltTracker, item: SushiBeltTrackerItem) {
    // ratio crossed down, OR the item left the set while above threshold
    // — end of the visible session, paired with the prior didEnter
  }
}
```

`tracksExit` is per-item, so a single tracker can freely mix sticky and
symmetric items.
