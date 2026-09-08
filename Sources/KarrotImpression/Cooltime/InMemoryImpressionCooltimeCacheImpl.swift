//
//  Created by jamie hyeon on 3/23/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

public final class InMemoryImpressionCooltimeCacheImpl: ImpressionCooltimeCache {

  private struct CacheState {
    var expirations: [String: Date] = [:]
    var lastSweepAt: Date = .distantPast
  }

  // MARK: - properties

  private let state: Mutex = .init(CacheState())
  private let sweepInterval: TimeInterval
  private let dateProvider: () -> Date

  // MARK: - init

  public init(sweepInterval: TimeInterval = 60, dateProvider: @escaping () -> Date) {
    self.sweepInterval = sweepInterval
    self.dateProvider = dateProvider
  }

  // MARK: - ImpressionCooltimeCache

  public func isInCooltime(for key: String, coolingTime: TimeInterval) -> Bool {
    state.withLock { state in
      let now = dateProvider()

      if now.timeIntervalSince(state.lastSweepAt) >= sweepInterval {
        state.lastSweepAt = now
        state.expirations = state.expirations.filter { $0.value > now }
      }

      if let expiry = state.expirations[key], expiry > now {
        return true
      }
      state.expirations[key] = now.addingTimeInterval(coolingTime)
      return false
    }
  }

  public func clear() {
    state.withLock { $0 = CacheState() }
  }
}

