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

  /// - Warning: 동일 Mutex의 withLock 블록 안에서 이 메서드를 다시 호출하면
  ///            (UnfairLock이 재진입 불가 특성이라) 교착상태가 발생할 수 있어요.
  @discardableResult
  func withLock<U>(_ mutation: (inout Value) throws -> U) rethrows -> U {
    try lock.around {
      try mutation(&value)
    }
  }
}

extension Mutex {

  /// 특정 프로퍼티의 값만 반환이 필요한 경우에 사용해요.
  /// - Note: 반환 타입이 reference type이면 반환 이후 변경은 Thread-Safe 하지 않아요.
  func withLock() -> Value {
    lock.around { value }
  }

  /// 특정 프로퍼티의 값만 반환이 필요한 경우에 사용해요.
  func withLock<U>(_ keyPath: KeyPath<Value, U>) -> U {
    lock.around {
      value[keyPath: keyPath]
    }
  }

  /// 특정 프로퍼티의 값만 업데이트가 필요한 경우에 사용해요.
  /// - Note: `mutation`이 throw를 던질 수 있고 결과를 반환할 수 있어요.
  /// - Warning: 동일 Mutex의 withLock 블록 안에서 이 메서드를 다시 호출하면
  ///            (UnfairLock이 재진입 불가 특성이라) 교착상태가 발생할 수 있어요.
  func withLock<U, R>(
    _ keyPath: WritableKeyPath<Value, U>,
    mutation: (inout U) throws -> R,
  ) rethrows -> R {
    try lock.around {
      try mutation(&value[keyPath: keyPath])
    }
  }
}

