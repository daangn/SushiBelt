//
//  ViewVisibleTrackerDebugger.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

public protocol ViewVisibleTrackerDebuggerLogic: AnyObject {
  func show()
  func hide()
  func configure(_ configuration: ViewVisibleTrackerDebuggerConfiguration)
  func update(items: Set<ViewVisibleTrackingItem>, scrollDirection: ViewVisibleTrackerScrollDirection?)
}

public final class ViewVisibleTrackerDebugger: ViewVisibleTrackerDebuggerLogic {
  
  private lazy var window: UIWindow = {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = ViewVisibleTrackerDebugViewController()
    window.isUserInteractionEnabled = false
    return window
  }()
  
  private var rootViewController: ViewVisibleTrackerDebugViewController? {
    return self.window.rootViewController as? ViewVisibleTrackerDebugViewController
  }
  
  private var configuration: ViewVisibleTrackerDebuggerConfiguration = .init()
  
  public static let shared = ViewVisibleTrackerDebugger()
  
  public func show() {
    self.window.isHidden = false
  }
  
  public func hide() {
    self.window.isHidden = true
  }
  
  public func configure(_ configuration: ViewVisibleTrackerDebuggerConfiguration) {
    self.configuration = configuration
  }
  
  public func update(items: Set<ViewVisibleTrackingItem>,
                     scrollDirection: ViewVisibleTrackerScrollDirection?) {
    self.rootViewController?.reload(
      items: items
        .sorted(by: { lhs, rhs -> Bool in
          return lhs.timestamp > rhs.timestamp
        })
        .map { item -> ViewVisibleTrackerDebugItemView.ViewModel in
          return ViewVisibleTrackerDebugItemView.ViewModel(
            status: item.status,
            description: self.description(item: item),
            frameInWindow: item.frameInWindow,
            scrollDirection: scrollDirection
          )
        },
      configuration: self.configuration
    )
  }
  
  private func description(item: ViewVisibleTrackingItem) -> String {
    if let description = self.configuration.description?(item) {
      return description
    }
    
    return item.defaultDescirption()
  }
}
