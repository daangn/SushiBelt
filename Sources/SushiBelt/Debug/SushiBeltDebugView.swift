//
//  SushiBeltDebugView.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

final class SushiBeltDebugView: UIView {
  
  private var itemViews: [SushiBeltDebugItemView] = []
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.itemViews.forEach {
      $0.updateFrameIfNeeded()
    }
  }
  
  func reload(items: [SushiBeltDebugItemView.ViewModel],
              configuration: SushiBeltDebuggerConfiguration) {
    self.itemViews.forEach {
      $0.removeFromSuperview()
    }
    
    self.itemViews = items.map {
      let view = SushiBeltDebugItemView(
        font: configuration.font,
        textColor: configuration.textColor,
        numberOfLine: configuration.numberOfLine,
        statusBackgroundColor: configuration.statusBackgroundColor,
        labelMargin: configuration.labelMargin
      )
      view.configure(viewModel: $0)
      self.addSubview(view)
      return view
    }
    
    self.setNeedsLayout()
  }
}
