//
//  SushiBeltDebugger.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

protocol SushiBeltDebuggerLogic: AnyObject {
  func show()
  func hide()
  func configure(_ configuration: SushiBeltDebuggerConfiguration)
  func update(items: Set<SushiBeltTrackerItem>)
}

final class SushiBeltDebugger: SushiBeltDebuggerLogic {
  
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
  
  static let shared = SushiBeltDebugger()
  
  func show() {
    self.window.isHidden = false
  }
  
  func hide() {
    self.window.isHidden = true
  }
  
  func configure(_ configuration: SushiBeltDebuggerConfiguration) {
    self.configuration = configuration
  }
  
  func update(items: Set<SushiBeltTrackerItem>) {
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
