//
//  ViewVisibleTrackingItem.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/07.
//

import Foundation
import UIKit

public protocol ViewVisibleTrackingIdentifier {
  var trackingIdentifer: String { get }
}

public struct ViewVisibleTrackingItem: Hashable, Equatable, CustomDebugStringConvertible {
  
  public enum Identifier: Equatable {
    case index(Int)
    case indexPath(IndexPath)
    case trackingIdentifier(ViewVisibleTrackingIdentifier)
    
    public static func == (lhs: ViewVisibleTrackingItem.Identifier,
                           rhs: ViewVisibleTrackingItem.Identifier) -> Bool {
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
  var frameInWindow: CGRect
  var isTracked: Bool = false
  
  public init(id: Identifier, view: UIView) {
    self.id = id
    self.frameInWindow = view.convert(view.bounds, to: nil)
  }
  
  public var debugDescription: String {
    switch self.id {
    case let .index(index):
      return "\(index), frame: \(self.frameInWindow)"
    case let .indexPath(indexPath):
      return "\(indexPath.section)-\(indexPath.item), frame: \(self.frameInWindow)"
    case let .trackingIdentifier(id):
      return "\(id.trackingIdentifer), frame: \(self.frameInWindow)"
    }
  }
  
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
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}
