# KarrotImpression

Impression tracking for UIKit and SwiftUI, with configurable visibility
thresholds and cooldowns. Receive callbacks and connect them to your analytics.

- **UIKit:** Track table and collection view cells, or provide custom targets.
- **SwiftUI:** Track views with modifiers and optional exit callbacks.

## Requirements

- iOS 17 or later
- Swift tools 6.1 or later (Swift 5 language mode)

Swift Package Manager resolves RxSwift and RxCocoa 6.8.0 automatically.

## Installation

Add the package using Swift Package Manager. For a local checkout, choose
**File → Add Package Dependencies → Add Local** in Xcode and select the repository
directory. Add the **KarrotImpression** product to your app target.

```swift
import KarrotImpression
```

## UIKit

Keep one tracker per scroll view, register it once, and subscribe to impressions.
Use stable model IDs and update `ProductCell.impressionID` when configuring a cell.

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

### Refreshing and filtering

The view-controller registration observes appearance, app activation, and user
scrolling. For programmatic scrolling or data reloads, call
`trackManually(shouldResetCache:)` after layout has updated the visible cells and
their frames.

| Method | Behavior |
| --- | --- |
| `trackManually(shouldResetCache: false)` | Evaluate items with existing tracking state. |
| `trackManually(shouldResetCache: true)` | Clear tracking state, then evaluate items. |
| `clearCache()` | Clear tracking state without evaluating items. |
| `setFilter(_:)` | Suppress callbacks when the filter returns `false`. |

A callback fires when an eligible item first meets its threshold. It can fire
again after the item leaves the tracked set or tracking state is cleared,
subject to its cooldown. UIKit's public API provides entry callbacks only.

### Registering while onscreen

A tracker registered while its view controller is already onscreen reports no
impression until that view controller appears again, and it stays silent when the
app returns from the background. Pass `usesInitialVisibility: true` to the builder
to take the visibility at registration time from the window attachment of the
view.

```swift
let tracker = ImpressionEventTrackerBuilder(usesInitialVisibility: true).build()
```

### Nested scroll views

For a nested scroll view, use the `register` overload without a view controller.
It does not observe screen or app lifecycle events. A parent tracking target can
conform to `ImpressionInnerScrollable` and forward its tracking and clearing
requests to the nested tracker.

### Cooldowns

Set `ImpressionCooltime` to limit repeated impressions, as in the 30-second
example above. Omit `cooltime` to disable cooldown checking for an item.

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

`tracker.clearCache()` and `shouldResetCache: true` preserve cooldowns. Use
`cache.clear()` to reset them. Implement `ImpressionCooltimeCache` for custom storage.

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
  }
}
```

An item is visible when its intersection with the container has positive area
and its visible-area ratio is at least `visibilityThreshold`. The default
threshold is `0.0`, meaning any positive intersection. IDs must be unique within
the container and remain stable across view updates.

Set `tracksExit: true` to pair accepted entries with exits when an item falls
below its threshold or leaves the visible set. Lifecycle exits are best-effort
when the container becomes inactive or disappears. Entries blocked by a policy
do not produce exits. By default, only entry callbacks are delivered.

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

### UIKit

For item diagnostics, call `tracker.enableDebugging()` from a
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

### SwiftUI

Add `.showsChildrenImpressionRect()` after `.impressionTrackableContainer()` to
show item overlays in debug builds. It has no effect in release builds.

Green outlines indicate items in the last processed visible snapshot, including
items blocked by a policy; they do not confirm callback delivery.

## Migrating from SushiBelt

The repository remains named SushiBelt; the package and import are
`KarrotImpression`. Replace the previous tracker and delegate APIs with the UIKit
builder and factory API or SwiftUI modifiers.

See the [migration guide](MIGRATION.md) for API mappings and behavior changes.
The `Example/` project uses the previous SushiBelt API.

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
