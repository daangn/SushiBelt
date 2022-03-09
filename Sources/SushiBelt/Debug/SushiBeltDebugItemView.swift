//
//  SushiBeltDebugItemView.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation
import UIKit

final class SushiBeltDebugItemView: UIView {
  
  struct ViewModel {
    let status: SushiBeltTrackerItemStatus
    let description: String
    let frameInWindow: CGRect
    let scrollDirection: SushiBeltTrackerScrollDirection?
  }
  
  // MARK: - UI
  
  private let label = UILabel()
  
  // MARK: - Prop
  
  private var viewModel: ViewModel?
  private var statusBackgroundColor: ((SushiBeltTrackerItemStatus) -> UIColor)?
  private let labelMargin: UIEdgeInsets
  
  init(
    font: UIFont,
    textColor: UIColor,
    numberOfLine: Int,
    statusBackgroundColor: ((SushiBeltTrackerItemStatus) -> UIColor)?,
    labelMargin: UIEdgeInsets
  ) {
    self.labelMargin = labelMargin
    super.init(frame: .zero)
    self.label.font = font
    self.label.textColor = textColor
    self.label.numberOfLines = numberOfLine
    self.statusBackgroundColor = statusBackgroundColor
    self.addSubview(self.label)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.label.sizeToFit()
    switch self.viewModel?.scrollDirection {
    case .up:
      self.label.frame.origin = CGPoint(
        x: self.labelMargin.left,
        y: self.labelMargin.top
      )
    case .down:
      self.label.frame.origin = CGPoint(
        x: self.labelMargin.left,
        y: self.bounds.height - self.labelMargin.top - self.label.frame.height
      )
    case .left:
      self.label.frame.origin = CGPoint(
        x: self.labelMargin.left,
        y: self.labelMargin.top
      )
    case .right:
      self.label.frame.origin = CGPoint(
        x: self.bounds.width - self.labelMargin.right - self.label.frame.width,
        y: self.labelMargin.left
      )
    case .none:
      break
    }
  }
  
  func updateFrameIfNeeded() {
    self.frame = self.viewModel?.frameInWindow ?? .zero
  }
  
  func configure(viewModel: ViewModel) {
    self.viewModel = viewModel
    self.label.text = viewModel.description
    self.backgroundColor = self.statusBackgroundColor(status: viewModel.status)
  }
  
  private func statusBackgroundColor(status: SushiBeltTrackerItemStatus) -> UIColor {
    if let color = self.statusBackgroundColor?(status) {
      return color
    }
    
    // default
    switch status {
    case .tracking:
      return UIColor(red: 0.6, green: 0.4, blue: 0.1, alpha: 0.4)
    case .tracked:
      return UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 0.4)
    }
  }
}
