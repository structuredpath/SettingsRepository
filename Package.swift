// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SettingsRepository",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "SettingsRepository",
            targets: ["SettingsRepository"]
        ),
        .library(
            name: "SettingsRepositoryCombine",
            targets: ["SettingsRepositoryCombine"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.2"),
        .package(url: "https://github.com/structuredpath/CombineExtensions", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "SettingsRepository",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
            ]
        ),
        .target(
            name: "SettingsRepositoryCombine",
            dependencies: [
                "SettingsRepository",
                .product(name: "CombineExtensions", package: "CombineExtensions"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ]
        ),
        .testTarget(
            name: "SettingsRepositoryTests",
            dependencies: [
                "SettingsRepository",
            ]
        ),
        .testTarget(
            name: "SettingsRepositoryCombineTests",
            dependencies: [
                "SettingsRepositoryCombine",
            ]
        ),
    ]
)
