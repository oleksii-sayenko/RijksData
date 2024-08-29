// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NetworkCore",
            targets: ["NetworkCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", exact: "0.54.0"),
    ],
    targets: [
        .target(
            name: "NetworkCore"
        ),
        .testTarget(
            name: "NetworkCoreTests",
            dependencies: ["NetworkCore"]
        )
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency"))
    target.swiftSettings = settings
    
    var plugins = target.plugins ?? []
    plugins.append(.plugin(name: "SwiftLintPlugin", package: "SwiftLint"))
    target.plugins = plugins
}
