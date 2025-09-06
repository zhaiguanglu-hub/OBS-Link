// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OBSLive",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OBSLive",
            targets: ["OBSLive"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/shogo4405/HaishinKit.swift", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "OBSLive",
            dependencies: [
                .product(name: "HaishinKit", package: "HaishinKit.swift")
            ]
        )
    ]
)