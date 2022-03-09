//
//  SushiBeltDebuggerConfiguration.swift
//  SushiBelt
//
//  Created by david on 2022/03/08.
//

import Foundation

public struct SushiBeltDebuggerConfiguration {
  
  let font: UIFont
  let textColor: UIColor
  let numberOfLine: Int
  let statusBackgroundColor: ((SushiBeltTrackerItemStatus) -> UIColor)?
  let description: ((SushiBeltTrackerItem) -> String)?
  let labelMargin: UIEdgeInsets
  
  public init(
    font: UIFont = UIFont.boldSystemFont(ofSize: 16.0),
    textColor: UIColor = .white,
    numberOfLine: Int = 0,
    statusBackgroundColor: ((SushiBeltTrackerItemStatus) -> UIColor)? = nil,
    description: ((SushiBeltTrackerItem) -> String)? = nil,
    labelMargin: UIEdgeInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
  ) {
    self.font = font
    self.textColor = textColor
    self.numberOfLine = numberOfLine
    self.statusBackgroundColor = statusBackgroundColor
    self.description = description
    self.labelMargin = labelMargin
  }
}
