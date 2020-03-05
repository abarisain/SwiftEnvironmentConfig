// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnvironmentConfigTools",
    products: [
    ],
    dependencies: [
        // Dev dependencies
        // Install these locally so we can use "swift run <tool>"
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.44.1"),
    ],
    targets: [
    ]
)
