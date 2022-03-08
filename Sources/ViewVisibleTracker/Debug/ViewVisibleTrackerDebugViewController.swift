//
//  ViewVisibleTrackerDebugViewController.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

final class ViewVisibleTrackerDebugViewController: UIViewController {
  
  private var contentView: ViewVisibleTrackerDebugView? {
    return self.view as? ViewVisibleTrackerDebugView
  }
  
  override func loadView() {
    self.view = ViewVisibleTrackerDebugView(frame: .zero)
  }
  
  func reload(items: [ViewVisibleTrackerDebugItemView.ViewModel],
              configuration: ViewVisibleTrackerDebuggerConfiguration) {
    self.contentView?.reload(
      items: items,
      configuration: configuration
    )
  }
}
