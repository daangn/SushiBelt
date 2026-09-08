//
//  Created by jamie hyeon on 6/23/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// Selects impression entries and exits without invoking their callbacks.
///
/// Compares visibility snapshots and outstanding entries, consulting the policy
/// for new entries. The caller invokes the selected callbacks and stores the
/// returned state. Policy evaluation may update the policy's own storage.
struct ImpressionFiringDecideUseCase {

  /// Callbacks to invoke and state to retain for the next update.
  struct Decision {

    /// Entries whose `onImpressionEnter()` callbacks should be invoked.
    let entriesToFire: [ImpressionEntry]

    /// Entries whose `onImpressionExit()` callbacks should be invoked.
    ///
    /// Includes previously entered items with `tracksExit == true` that are no longer visible.
    let entriesToExit: [ImpressionEntry]

    /// The visible snapshot to use for the next comparison.
    let snapshot: Set<ImpressionEntry>

    /// Entered items awaiting an exit, retained for the next comparison.
    let enteredEntries: Set<ImpressionEntry>
  }

  /// Selects policy-allowed entries newly added to the visible snapshot and
  /// previously entered items that are no longer visible.
  ///
  /// Policy-suppressed entries never enter `enteredEntries`. Only items whose
  /// entry fired with `tracksExit == true` can produce an exit.
  ///
  /// - Parameters:
  ///   - currentlyVisible: Entries currently reported as visible.
  ///   - lastSnapshot: The last processed visible snapshot.
  ///   - enteredEntries: Entered items with exit tracking that have not exited yet.
  ///   - allowsImpression: A policy check by item ID. `nil` allows every new entry.
  /// - Returns: Entries and exits to fire, plus the updated snapshot and outstanding entries.
  func execute(
    currentlyVisible: Set<ImpressionEntry>,
    lastSnapshot: Set<ImpressionEntry>,
    enteredEntries: Set<ImpressionEntry>,
    allowsImpression: ((AnyHashable) -> Bool)?,
  ) -> Decision {
    let added = currentlyVisible.subtracting(lastSnapshot)
    let entriesToFire = added.filter { allowsImpression?($0.item.id) ?? true }

    let visibleIDs = Set(currentlyVisible.map(\.item.id))
    let entriesToExit = enteredEntries.filter { !visibleIDs.contains($0.item.id) }

    // Refresh retained entries from the current report so exit callbacks use its latest captures.
    let nextEnteredIDs = Set(enteredEntries.subtracting(entriesToExit).map(\.item.id))
      .union(entriesToFire.filter(\.item.tracksExit).map(\.item.id))
    let nextEntered = currentlyVisible.filter { nextEnteredIDs.contains($0.item.id) }

    return Decision(
      entriesToFire: Array(entriesToFire),
      entriesToExit: Array(entriesToExit),
      snapshot: currentlyVisible,
      enteredEntries: nextEntered,
    )
  }
}

