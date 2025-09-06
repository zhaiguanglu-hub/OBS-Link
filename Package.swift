// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OBSLiveiOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OBSLiveiOS",
            targets: ["OBSLiveiOS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/shogo4405/HaishinKit.swift.git", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "OBSLiveiOS",
            dependencies: [
                .product(name: "HaishinKit", package: "HaishinKit.swift")
            ]
        ),
        .testTarget(
            name: "OBSLiveiOSTests",
            dependencies: ["OBSLiveiOS"]
        ),
    ]
)