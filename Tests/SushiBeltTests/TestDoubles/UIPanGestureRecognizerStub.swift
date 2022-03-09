//
//  UIPanGestureRecognizerStub.swift
//  SushiBeltTests
//
//  Created by david on 2022/03/09.
//

import Foundation
import UIKit

final class UIPanGestureRecognizerStub: UIPanGestureRecognizer {
  
  var velocityStub: CGPoint = .zero
  
  override func velocity(in view: UIView?) -> CGPoint {
    return self.velocityStub
  }
  
}
