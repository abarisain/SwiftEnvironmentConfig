// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnvironmentConfig",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "EnvironmentConfig",
            targets: ["EnvironmentConfig"]),
    ],
    dependencies: [
        // Test dependencies
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "EnvironmentConfig",
            dependencies: []),
        .testTarget(
            name: "EnvironmentConfigTests",
            dependencies: {
                var deps: [Target.Dependency] = ["EnvironmentConfig"]
                #if os(macOS)
                    deps.append("CwlPreconditionTesting")
                #else
                    deps.append("CwlPosixPreconditionTesting")
                #endif
                return deps
            }()
        )
    ]
)
