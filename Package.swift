// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RKMultiUnitRuler",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RKMultiUnitRuler",
            targets: ["RKMultiUnitRuler"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "RKMultiUnitRuler",
            dependencies: []),
        .testTarget(
            name: "RKMultiUnitRulerTests",
            dependencies: ["RKMultiUnitRuler"]),
    ]
)
