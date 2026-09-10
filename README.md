# KarrotImpression

Impression tracking for UIKit and SwiftUI. Choose how much of an item must be
visible, control repeated impressions, and handle callbacks in your own analytics
code. KarrotImpression detects visibility; it does not send analytics events.

The repository is named **SushiBelt**. The package, library product, and Swift
module are named **KarrotImpression**. The original SushiBelt engine is an
implementation detail, not a separate public product.

## Requirements

- iOS 17 or later
- Swift tools 6.1 or later; the package uses Swift 5 language mode
- RxSwift and RxCocoa 6.8.0, resolved by Swift Package Manager

No private Karrot packages or dependency-injection framework are required.

## Installation

This version is unreleased. Existing SushiBelt release tags and the CocoaPods
spec do not provide the API described here.

To try this branch in Xcode, check it out locally, choose **File → Add Package
Dependencies → Add Local**, and select the repository directory. Add the
**KarrotImpression** product to your app target.

```swift
import KarrotImpression
```

## UIKit

Keep one tracker for each scroll view. Register it once, supply the items to
measure, and subscribe to impression callbacks. Use stable model IDs rather than
cell instances or index paths that change when the list is reordered.

This example wires an existing collection view to the tracker. Configure
`ProductCell.impressionID` from your model whenever a cell is reused.

```swift
import UIKit
import KarrotImpression

final class ProductCell: UICollectionViewCell {
  var impressionID: String?
}

final class ProductListViewController: UIViewController {
  @IBOutlet private weak var collectionView: UICollectionView!
  private let tracker = ImpressionEventTrackerBuilder().build()

  override func viewDidLoad() {
    super.viewDidLoad()

    let factory = DefaultDetectorItemFactory { view in
      guard let cell = view as? ProductCell,
            let id = cell.impressionID else {
        return nil
      }

      return VisibleStateDetectorItem(
        id: id,
        target: cell,
        ratio: 0.5,
        cooltime: ImpressionCooltime(key: id, coolingTime: 30)
      )
    }

    tracker.subscribe { item in
      print("Impression: \(item.id)")
    }
    tracker.register(
      viewController: self,
      scrollView: collectionView,
      detectorItemFactory: factory,
      trackingRect: { [weak self] in
        guard let scrollView = self?.collectionView else { return .zero }
        return scrollView.convert(scrollView.bounds, to: nil)
      }
    )
  }
}
```

`ratio: 0.5` requires at least half of the target's area to intersect the tracking
area. Both `trackingRect` and the target's `frameInWindow` use **window
coordinates**. The closure above uses the scroll view's bounds; adjust it if a
fixed header or another overlay should reduce the tracking area. The library
does not infer occlusion by other views.

`DefaultDetectorItemFactory` maps visible cells in `UITableView` and
`UICollectionView`. It does not include supplementary views or arbitrary
`UIScrollView` subviews. Implement `DetectorItemFactory` for those cases; any
`UIView` already conforms to `ImpressionDetectorTarget`.

### Lifecycle and refreshes

The view-controller registration observes appearance, app activation, and user
scrolling. For programmatic scrolling or data reloads, call
`trackManually(shouldResetCache:)` after layout has updated the visible cells and
their frames.

- `trackManually(shouldResetCache: false)` evaluates items with existing tracking state.
- `trackManually(shouldResetCache: true)` clears tracked-item state before evaluating.
- `clearCache()` clears tracked-item state without starting a new evaluation.
- `setFilter(_:)` suppresses callbacks for items where the closure returns `false`.

A callback fires when an eligible item first meets its threshold. It can fire
again after the item leaves the tracked set or tracking state is cleared,
subject to its cooldown. UIKit's public API provides entry callbacks only.

For a nested scroll view, use the `register` overload without a view controller.
It does not observe screen or app lifecycle events. A parent tracking target can
conform to `ImpressionInnerScrollable` and forward its tracking and clearing
requests to the nested tracker.

### Cooldowns and cache ownership

The example sets a 30-second cooldown using `ImpressionCooltime`. Omitting
`cooltime` disables cooldown checking for that item; it does not use the item ID
as an implicit cache key.

Each `build()` call creates a separate in-memory cooldown cache. To share a
cooldown across trackers, inject the same cache and use the same cooldown keys:

```swift
let cache = InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() })
let builder = ImpressionEventTrackerBuilder()
let firstTracker = builder.build(cooltimeCache: cache)
let secondTracker = builder.build(cooltimeCache: cache)
```

The tracker applies its filter before checking the cooldown. The default cache
records an expiration when a check allows an impression.

**Tracking state and cooldown state are separate.** `tracker.clearCache()` and
`shouldResetCache: true` do not clear cooldowns. Call `cache.clear()` explicitly
if your refresh or session policy requires that. You can provide custom storage
by implementing `ImpressionCooltimeCache`.

## SwiftUI

Mark each item with `impressionTrackable` and wrap the list in
`impressionTrackableContainer`. Add `impressionPolicy` after the container
modifier so the policy is available to it through the environment.

```swift
import SwiftUI
import KarrotImpression

struct ProductList: View {
  let productIDs: [String]

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(productIDs, id: \.self) { id in
          Text(id)
            .frame(maxWidth: .infinity, minHeight: 120)
            .impressionTrackable(
              id: id,
              visibilityThreshold: 0.5,
              tracksExit: true,
              onImpressionEnter: { print("Enter: \(id)") },
              onImpressionExit: { print("Exit: \(id)") }
            )
        }
      }
    }
    .impressionTrackableContainer(visibleArea: .safeArea)
    .impressionPolicy(.cooldown(interval: 30))
    .showsChildrenImpressionRect()
  }
}
```

An item is visible when its intersection with the container has positive area
and its visible-area ratio is at least `visibilityThreshold`. The default
threshold is `0.0`, meaning any positive intersection. IDs must be unique within
the container and remain stable across view updates.

Without `tracksExit: true`, only entry callbacks are delivered. With exit
tracking enabled, an accepted entry is paired with an exit when the item falls
below its threshold or leaves the visible set. Exits are also attempted when
the container becomes inactive or disappears; crashes and forced termination
cannot guarantee a final callback. A policy-blocked entry does not produce an
exit callback.

### Visible area and policies

The container's default is `.ignoringSafeArea()`. Use `.safeArea` to respect
safe-area insets, or `.ignoringSafeArea(regions: .container, edges: .bottom)` to ignore
only selected insets.

Without a policy, entries are allowed whenever an item newly qualifies as
visible. `.cooldown(interval:)` suppresses repeated entries for the same ID.
Policy storage belongs to the modifier's SwiftUI state: it survives body
recomputations but is recreated when the policy ID changes or the modifier's
state is destroyed. Implement `ImpressionPolicy` for another rule.

With unchanged item configuration, cooldown expiration alone does not trigger a
callback. A blocked item must leave and reenter the visible set, or the container
must reactivate, before it can be considered again. SwiftUI policy storage is
independent of UIKit's `ImpressionCooltimeCache`.

## Debugging

All debug views use UIKit or SwiftUI; no app-specific debug menu is required.

For UIKit item diagnostics, call `tracker.enableDebugging()` from a
`#if DEBUG` block. For tracking-area and safe-area overlays, present the settings
controller from your own debug menu:

```swift
#if DEBUG
let settings = ImpressionDebugOverlaySettingsViewController()
present(settings, animated: true)
#endif
```

The settings controller is available only in `DEBUG` builds. Orange outlines
show reported UIKit tracking areas; the cyan dashed outline shows the topmost
screen's safe area. Enable the toggle, then scroll or reenter the screen to
refresh tracking-area reports.

In SwiftUI, `showsChildrenImpressionRect()` adds red and green item overlays in
debug builds and does nothing in release builds. Green means the item is in the
container's last processed visible snapshot, which includes items blocked by a
policy. It is **not** confirmation that an impression callback was delivered.

## Migrating from SushiBelt

This is not an import-only rename. `SushiBeltTracker`, its delegate/data-source
protocols, and engine customization types are now internal. Use the UIKit
builder and factory API or the SwiftUI modifiers instead.

See [MIGRATION.md](MIGRATION.md) for the public API changes and the older
SushiBelt 2.x-to-3.0 guide. The `Example/` CocoaPods project still targets the
older SushiBelt API; it is not a runnable KarrotImpression sample.

## Authors

- [Geektree0101](https://www.github.com/Geektree0101)
- [ElonPark](https://www.github.com/ElonPark)
- [jinsu3758](https://www.github.com/jinsu3758)
- [jaxtynSong](https://github.com/jaxtynSong)
- [KYHyeon](https://github.com/KYHyeon)

## License

KarrotImpression is distributed under the Apache License, Version 2.0, except
for third-party code with its own license notices. The RxViewController-derived
lifecycle extensions retain their MIT license. See [LICENSE](LICENSE).
