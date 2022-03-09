//
//  SushiBeltDebugViewController.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

final class SushiBeltDebugViewController: UIViewController {
  
  private var contentView: SushiBeltDebugView? {
    return self.view as? SushiBeltDebugView
  }
  
  override func loadView() {
    self.view = SushiBeltDebugView(frame: .zero)
  }
  
  func reload(items: [SushiBeltDebugItemView.ViewModel],
              configuration: SushiBeltDebuggerConfiguration) {
    self.contentView?.reload(
      items: items,
      configuration: configuration
    )
  }
}
