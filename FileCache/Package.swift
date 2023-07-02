// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileCache",
    products: [
        .library(
            name: "FileCache",
            targets: ["FileCache"])
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.0")
    ],
    targets: [

        .target(
            name: "FileCache",
            dependencies: [
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack")
            ]),
        .testTarget(
            name: "FileCacheTests",
            dependencies: ["FileCache"])
    ]
)
