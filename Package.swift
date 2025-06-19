// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CarespaceSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "CarespaceSDK",
            targets: ["CarespaceSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CarespaceSDK",
            dependencies: []),
        .testTarget(
            name: "CarespaceSDKTests",
            dependencies: ["CarespaceSDK"]),
    ]
)