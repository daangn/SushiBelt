//
//  Created by Jaxtyn Song on 3/25/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// UIKit의 뷰 라이프사이클 이벤트를 SwiftUI에서 사용하기 위한 브릿지.
///
/// SwiftUI의 `onAppear`는 UIKit의 `viewDidAppear`와 호출 시점이 다릅니다.
/// 특히 NavigationStack에서 back swipe(인터랙티브 팝 제스처) 시,
/// 이전 화면이 살짝만 보여도 `onAppear`가 호출되는 문제가 있습니다.
///
/// 이 브릿지는 `UIViewControllerRepresentable`을 통해 UIKit의 정확한
/// `viewDidAppear` 타이밍과 인터랙티브 전환 상태를 감지합니다.
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

  /// UIKit의 `viewDidAppear` 타이밍에 맞춰 액션을 실행합니다.
  ///
  /// - Parameters:
  ///   - action: `viewDidAppear` 시점에 실행할 콜백
  ///   - onDisappearing: 뷰가 사라지기 시작할 때 실행할 콜백
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

