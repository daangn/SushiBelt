//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// Exposes UIKit view lifecycle callbacks to SwiftUI.
///
/// Uses `viewDidAppear` to avoid starting tracking from an early SwiftUI `onAppear`
/// during an interactive navigation transition. `viewWillDisappear` signals when
/// the container should stop accepting geometry and visibility updates.
///
/// The bridge forwards lifecycle callbacks; it does not inspect transition progress.
struct UIKitLifecycleBridge: UIViewControllerRepresentable {
  var onDidAppear: (() -> Void)?
  var onDisappearing: (() -> Void)?

  func makeUIViewController(context: Context) -> UIViewController {
    let controller = ObserverViewController()
    controller.onDidAppear = onDidAppear
    controller.onDisappearing = onDisappearing
    return controller
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    guard let observer = uiViewController as? ObserverViewController else { return }
    observer.onDidAppear = onDidAppear
    observer.onDisappearing = onDisappearing
  }

  // MARK: - ObserverViewController

  class ObserverViewController: UIViewController {
    var onDidAppear: (() -> Void)?
    var onDisappearing: (() -> Void)?

    override func viewDidLoad() {
      super.viewDidLoad()

      view.backgroundColor = .clear
      view.isUserInteractionEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      onDidAppear?()
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      onDisappearing?()
    }
  }
}

extension View {

  /// Runs an action when the embedded UIKit controller receives `viewDidAppear`.
  ///
  /// - Parameters:
  ///   - action: The callback for `viewDidAppear`.
  ///   - onDisappearing: The callback for `viewWillDisappear`.
  func onDidAppear(
    _ action: @escaping () -> Void,
    onDisappearing: (() -> Void)? = nil
  ) -> some View {
    background(
      UIKitLifecycleBridge(
        onDidAppear: action,
        onDisappearing: onDisappearing
      )
      .allowsHitTesting(false)
    )
  }
}

