//
//  SushiBeltDebugger.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

public protocol SushiBeltDebuggerLogic: AnyObject {
  func show()
  func hide()
  func configure(_ configuration: SushiBeltDebuggerConfiguration)
  func update(items: Set<SushiBeltTrackerItem>)
}

public final class SushiBeltDebugger: SushiBeltDebuggerLogic {
  
  private lazy var window: UIWindow = {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = SushiBeltDebugViewController()
    window.isUserInteractionEnabled = false
    return window
  }()
  
  private var rootViewController: SushiBeltDebugViewController? {
    return self.window.rootViewController as? SushiBeltDebugViewController
  }
  
  private var configuration: SushiBeltDebuggerConfiguration = .init()
  
  public static let shared = SushiBeltDebugger()
  
  public func show() {
    self.window.isHidden = false
  }
  
  public func hide() {
    self.window.isHidden = true
  }
  
  public func configure(_ configuration: SushiBeltDebuggerConfiguration) {
    self.configuration = configuration
  }
  
  public func update(items: Set<SushiBeltTrackerItem>) {
    self.rootViewController?.reload(
      items: items
        .sorted(by: { lhs, rhs -> Bool in
          return lhs.timestamp > rhs.timestamp
        })
        .map { item -> SushiBeltDebugItemView.ViewModel in
          return SushiBeltDebugItemView.ViewModel(
            status: item.status,
            description: self.description(item: item),
            frameInWindow: item.rect.frameInWindow
          )
        },
      configuration: self.configuration
    )
  }
  
  private func description(item: SushiBeltTrackerItem) -> String {
    if let description = self.configuration.description?(item) {
      return description
    }
    
    return item.defaultDescirption()
  }
}
