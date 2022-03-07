// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "ViewVisibleTracker",
  platforms: [
    .iOS(.v11),
  ],
  products: [
    .library(
      name: "ViewVisibleTracker",
      targets: ["ViewVisibleTracker"]
    ),
  ],
  targets: [
    .target(
      name: "ViewVisibleTracker"
    ),
    .testTarget(
      name: "ViewVisibleTrackerTests",
      dependencies: [
        "ViewVisibleTracker"
      ]
    ),
  ]
)