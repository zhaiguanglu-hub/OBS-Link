// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OBSLive",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OBSLive",
            targets: ["OBSLive"]),
    ],
    dependencies: [
        // HaishinKit for RTMP streaming
        .package(url: "https://github.com/shogo4405/HaishinKit.swift", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "OBSLive",
            dependencies: [
                .product(name: "HaishinKit", package: "HaishinKit.swift")
            ],
            path: "OBSLive"
        ),
    ]
)