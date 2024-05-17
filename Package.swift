// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "SushiBelt",
  platforms: [
    .iOS(.v12),
  ],
  products: [
    .library(
      name: "SushiBelt",
      targets: ["SushiBelt"]
    ),
  ],
  targets: [
    .target(
      name: "SushiBelt"
    ),
    .testTarget(
      name: "SushiBeltTests",
      dependencies: [
        "SushiBelt"
      ]
    ),
  ]
)