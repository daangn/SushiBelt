//
//  SushiBeltTrackerItem.swift
//  SushiBelt
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol SushiBeltTrackerIdentifier {
  var trackingIdentifer: String { get }
}

public struct SushiBeltTrackerItem {
  
  public enum Identifier: Equatable {
    case index(Int)
    case indexPath(IndexPath)
    case trackingIdentifier(SushiBeltTrackerIdentifier)
    
    public static func == (lhs: SushiBeltTrackerItem.Identifier,
                           rhs: SushiBeltTrackerItem.Identifier) -> Bool {
      switch (lhs, rhs) {
      case let (.index(lhsIndex), .index(rhsIndex)):
        return lhsIndex == rhsIndex
      case let (.indexPath(lhsIndexPath), .indexPath(rhsIndexPath)):
        return lhsIndexPath.item == rhsIndexPath.item
        && lhsIndexPath.section == rhsIndexPath.section
      case let (.trackingIdentifier(lhsID), .trackingIdentifier(rhsID)):
        return lhsID.trackingIdentifer == rhsID.trackingIdentifer
      default:
        return false
      }
    }
  }
  
  public let id: Identifier
  public var status: SushiBeltTrackerItemStatus {
    return self.isTracked ? .tracked : .tracking
  }
  
  public var rect: SushiBeltTrackerItemRect
  public private(set) var timestamp: Date
  var isTracked: Bool = false
  var currentVisibleRatio: CGFloat = 0.0
  var objectiveVisibleRatio: CGFloat = 0.0
  
  public init(id: Identifier, rect: SushiBeltTrackerItemRect) {
    self.id = id
    self.rect = rect
    self.timestamp = Date()
  }
  
}

// MARK: - CustomDebugStringConvertible

extension SushiBeltTrackerItem: CustomDebugStringConvertible {
  
  public var debugDescription: String {
    switch self.id {
    case let .index(index):
      return "\(index), frame: \(self.rect.frameInWindow)"
    case let .indexPath(indexPath):
      return "\(indexPath.section)-\(indexPath.item), frame: \(self.rect.frameInWindow)"
    case let .trackingIdentifier(id):
      return "\(id.trackingIdentifer), frame: \(self.rect.frameInWindow)"
    }
  }
}

// MARK: - Hashable

extension SushiBeltTrackerItem: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    switch self.id {
    case let .index(index):
      hasher.combine(index)
    case let .indexPath(indexPath):
      hasher.combine(indexPath)
    case let .trackingIdentifier(id):
      hasher.combine(id.trackingIdentifer)
    }
  }
}

// MARK: - Equatable

extension SushiBeltTrackerItem: Equatable {
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}
