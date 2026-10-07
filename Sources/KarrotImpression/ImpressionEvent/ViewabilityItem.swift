import UIKit

/// Registers a UIKit target for enter/exit events, independently of impression policy.
/// Equality and hashing use `id`; the callback payload is captured on entry.
public struct ViewabilityItem: Identifiable, Hashable {
  public let id: String
  public let target: ImpressionDetectorTarget
  public let ratio: CGFloat
  public let userInfo: [AnyHashable: Any]?

  /// Ratios outside the finite `0...1` range are excluded from tracking.
  public init(
    id: String,
    target: ImpressionDetectorTarget,
    ratio: CGFloat,
    userInfo: [AnyHashable: Any]? = nil
  ) {
    self.id = id
    self.target = target
    self.ratio = ratio
    self.userInfo = userInfo
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}
