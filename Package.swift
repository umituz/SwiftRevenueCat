// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftRevenueCat",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftRevenueCat",
            targets: ["SwiftRevenueCat"])
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm", from: "5.70.0")
    ],
    targets: [
        .target(
            name: "SwiftRevenueCat",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios-spm")
            ],
            path: "Sources/SwiftRevenueCat"),
        .testTarget(
            name: "SwiftRevenueCatTests",
            dependencies: ["SwiftRevenueCat"],
            path: "Tests/SwiftRevenueCatTests")
    ]
)
