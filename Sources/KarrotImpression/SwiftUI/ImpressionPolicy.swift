//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A policy that decides whether an impression is allowed.
///
/// Apply a policy with `.impressionPolicy()` to customize when impressions may fire.
///
/// The modifier keeps policy state in `Storage`, backed by SwiftUI `@State`.
/// Storage survives body updates and resets when `policy.id` changes.
///
/// ```swift
/// List { ... }
///   .impressionTrackableContainer()
///   .impressionPolicy(.cooldown(interval: 60))
/// ```
/// @mockable(typealias: Storage = Void)
public protocol ImpressionPolicy {

  associatedtype Storage

  /// The identity used to determine whether policy storage should be reset.
  ///
  /// `ImpressionPolicyModifier` preserves `Storage` while this ID stays the same
  /// and creates fresh storage when it changes.
  var id: AnyHashable { get }

  /// Creates the policy's initial state.
  ///
  /// `ImpressionPolicyModifier` owns this storage in `@State` and resets it
  /// when the policy ID changes.
  static func makeStorage() -> Storage

  /// Decides whether to allow an impression for the given item ID.
  /// - Parameters:
  ///   - id: The tracked item's identifier.
  ///   - storage: Mutable state owned by the policy modifier.
  /// - Returns: `true` to allow the impression callback, or `false` to suppress it.
  func allowsImpression(for id: AnyHashable, storage: inout Storage) -> Bool
}

// MARK: - CooldownImpressionPolicy

/// Suppresses repeated impressions for the same item during a cooldown interval.
///
/// An impression is allowed once `interval` seconds have elapsed since the last
/// allowed impression. Timestamps live in the modifier's in-memory storage.
public struct CooldownImpressionPolicy: ImpressionPolicy {

  public struct TimestampStorage {
    var timestamps: [AnyHashable: Date] = [:]
  }

  public let id: AnyHashable
  private let interval: TimeInterval

  /// - Parameters:
  ///   - id: The policy's storage identity. Defaults to `"cooldown"`.
  ///   - interval: The minimum time between impressions of the same item, in seconds.
  public init(id: AnyHashable = "cooldown", interval: TimeInterval) {
    self.id = id
    self.interval = interval
  }

  public static func makeStorage() -> TimestampStorage {
    TimestampStorage()
  }

  public func allowsImpression(for id: AnyHashable, storage: inout TimestampStorage) -> Bool {
    let now = Date()

    guard let lastTracked = storage.timestamps[id] else {
      storage.timestamps[id] = now
      return true
    }

    if now.timeIntervalSince(lastTracked) < interval {
      return false
    }

    storage.timestamps[id] = now
    return true
  }
}

public extension ImpressionPolicy where Self == CooldownImpressionPolicy {

  /// Creates a cooldown policy.
  /// - Parameters:
  ///   - id: The policy's storage identity. Defaults to `"cooldown"`.
  ///   - interval: The minimum time between impressions of the same item, in seconds.
  static func cooldown(id: AnyHashable = "cooldown", interval: TimeInterval) -> Self {
    CooldownImpressionPolicy(id: id, interval: interval)
  }
}

