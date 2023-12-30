// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AppAttest",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        .library(
            name: "AppAttest",
            targets: ["AppAttest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/myfreeweb/SwiftCBOR", from: "0.4.6"),
        .package(url: "https://github.com/apple/swift-crypto", from: "3.1.0"),
        .package(url: "https://github.com/iansampson/Anchor", branch: "main"),
    ],
    targets: [
        .target(
            name: "AppAttest",
            dependencies: [
                "SwiftCBOR",
                .product(name: "Crypto", package: "swift-crypto"),
                "Anchor"
            ]
        ),
        .testTarget(
            name: "AppAttestTests",
            dependencies: ["AppAttest"]
        )
    ]
)
