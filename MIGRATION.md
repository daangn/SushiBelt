# Migration Guide

## 2.x → 3.0

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
