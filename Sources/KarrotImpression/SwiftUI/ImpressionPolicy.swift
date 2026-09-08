//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// 임프레션 발생 여부를 결정하는 정책 프로토콜.
///
/// `.impressionPolicy()`를 통해 주입하여, 임프레션이 허용되는 조건을 커스터마이즈할 수 있습니다.
///
/// `Storage`를 통해 정책이 필요로 하는 상태를 관리합니다.
/// SwiftUI body 재계산 시에도 `Storage`는 `@State`에 의해 보존되며,
/// `policy.id`가 변경될 때만 새로운 `Storage`가 생성됩니다.
///
/// ```swift
/// List { ... }
///   .impressionTrackableContainer()
///   .impressionPolicy(.cooldown(interval: 60))
/// ```
/// @mockable(typealias: Storage = Void)
public protocol ImpressionPolicy {

  associatedtype Storage

  /// 정책 인스턴스의 고유 식별자.
  ///
  /// `ImpressionPolicyModifier`가 `id` 변경을 감지하여 `Storage`를 재생성합니다.
  /// 동일한 `id`이면 기존 `Storage`(내부 상태 포함)가 보존됩니다.
  var id: AnyHashable { get }

  /// 정책이 사용할 `Storage`를 생성합니다.
  ///
  /// `ImpressionPolicyModifier`의 `@State`에서 관리되며,
  /// `id`가 변경될 때 새로운 `Storage`가 생성됩니다.
  static func makeStorage() -> Storage

  /// 해당 `id`의 임프레션을 허용할지 결정합니다.
  /// - Parameters:
  ///   - id: 임프레션 추적 대상의 식별자
  ///   - storage: 정책이 관리하는 상태 저장소
  /// - Returns: `true`이면 임프레션 콜백이 실행되고, `false`이면 무시됩니다.
  func allowsImpression(for id: AnyHashable, storage: inout Storage) -> Bool
}

// MARK: - CooldownImpressionPolicy

/// 일정 시간(쿨다운) 내 동일 아이템의 중복 임프레션을 방지하는 정책.
///
/// 마지막 임프레션으로부터 `interval`이 경과하지 않으면 임프레션을 허용하지 않습니다.
/// 메모리 기반으로 동작하며, 앱 종료 시 초기화됩니다.
public struct CooldownImpressionPolicy: ImpressionPolicy {

  public struct TimestampStorage {
    var timestamps: [AnyHashable: Date] = [:]
  }

  public let id: AnyHashable
  private let interval: TimeInterval

  /// - Parameters:
  ///   - id: 정책 인스턴스의 고유 식별자. 기본값은 `"cooldown"`.
  ///   - interval: 동일 아이템의 임프레션 간 최소 대기 시간 (초 단위)
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

  /// 쿨다운 기반 임프레션 정책을 생성합니다.
  /// - Parameters:
  ///   - id: 정책 인스턴스의 고유 식별자. 기본값은 `"cooldown"`.
  ///   - interval: 동일 아이템의 임프레션 간 최소 대기 시간 (초 단위)
  static func cooldown(id: AnyHashable = "cooldown", interval: TimeInterval) -> Self {
    CooldownImpressionPolicy(id: id, interval: interval)
  }
}

