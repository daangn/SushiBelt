//
//  Rx+UIViewController.swift
//  KarrotImpression
//
//  Adapted from RxViewController:
//  https://github.com/devxoul/RxViewController
//  Modifications Copyright © 2023 Danggeun Market Inc.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Suyeol Jeon (xoul.kr)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {

  var viewWillAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewWillAppear))
      .map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewDidAppear))
      .map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewDidDisappear))
      .map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var isVisible: Infallible<Bool> {
    Infallible.merge(
      base.rx.viewWillAppear.asInfallible().map { _ in true },
      base.rx.viewDidDisappear.asInfallible().map { _ in false },
    )
  }
}
