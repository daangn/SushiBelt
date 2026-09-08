//
//  UnfairLock.swift
//  KarrotImpression
//
//  Created by Elon on 2023/10/01.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation
import os

struct UnfairLock {

  private let unfairLock = OSAllocatedUnfairLock()

  init() {}

  func lock() {
    unfairLock.lock()
  }

  func unlock() {
    unfairLock.unlock()
  }

  func around<T>(_ closure: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try closure()
  }

  func around(_ closure: () throws -> Void) rethrows {
    lock()
    defer { unlock() }
    try closure()
  }
}

