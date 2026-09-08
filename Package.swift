// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "KarrotImpression",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "KarrotImpression",
      targets: ["KarrotImpression"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.8.0"),
  ],
  targets: [
    .target(
      name: "KarrotImpression",
      dependencies: [
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxCocoa", package: "RxSwift"),
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "SushiBeltTests",
      dependencies: [
        "KarrotImpression"
      ]
    ),
  ],
  swiftLanguageModes: [.v5]
)
