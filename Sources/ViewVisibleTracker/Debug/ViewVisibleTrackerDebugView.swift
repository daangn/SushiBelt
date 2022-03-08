//
//  ViewVisibleTrackerDebugView.swift
//  ViewVisibleTracker
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

final class ViewVisibleTrackerDebugView: UIView {
  
  private var itemViews: [ViewVisibleTrackerDebugItemView] = []
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.itemViews.forEach {
      $0.updateFrameIfNeeded()
    }
  }
  
  func reload(items: [ViewVisibleTrackerDebugItemView.ViewModel],
              configuration: ViewVisibleTrackerDebuggerConfiguration) {
    self.itemViews.forEach {
      $0.removeFromSuperview()
    }
    
    self.itemViews = items.map {
      let view = ViewVisibleTrackerDebugItemView(
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
