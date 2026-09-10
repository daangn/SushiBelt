//
//  Mutex.swift
//  KarrotImpression
//
//  Created by elon on 2022/05/19.
//  Copyright © 2022 Danggeun Market Inc. All rights reserved.
//

import Foundation

final class Mutex<Value> {

  private var value: Value
  private let lock = UnfairLock()

  init(_ value: Value) {
    self.value = value
  }

  /// - Warning: Do not call this method from another `withLock` block on the same
  /// mutex. `UnfairLock` is not recursive, so reentry can deadlock.
  @discardableResult
  func withLock<U>(_ mutation: (inout Value) throws -> U) rethrows -> U {
    try lock.around {
      try mutation(&value)
    }
  }
}

extension Mutex {

  /// Reads the stored value under the lock.
  /// - Note: If the value is a reference type, later mutations are not protected by this lock.
  func withLock() -> Value {
    lock.around { value }
  }

  /// Reads a property under the lock.
  func withLock<U>(_ keyPath: KeyPath<Value, U>) -> U {
    lock.around {
      value[keyPath: keyPath]
    }
  }

  /// Updates a property under the lock.
  /// - Note: The mutation can throw and return a result.
  /// - Warning: Do not call this method from another `withLock` block on the same
  /// mutex. `UnfairLock` is not recursive, so reentry can deadlock.
  func withLock<U, R>(
    _ keyPath: WritableKeyPath<Value, U>,
    mutation: (inout U) throws -> R,
  ) rethrows -> R {
    try lock.around {
      try mutation(&value[keyPath: keyPath])
    }
  }
}
