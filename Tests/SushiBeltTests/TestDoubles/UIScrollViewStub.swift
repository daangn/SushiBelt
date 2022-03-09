//
//  UIScrollViewStub.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

final class UIScrollViewStub: UIScrollView {
  
  var panGestureRecognizerStub: UIPanGestureRecognizer = UIPanGestureRecognizer()
  
  override var panGestureRecognizer: UIPanGestureRecognizer {
    return self.panGestureRecognizerStub
  }
  
}
