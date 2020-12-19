// swift-tools-version:5.3

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
        .package(url: "https://github.com/myfreeweb/SwiftCBOR", from: "0.4.3"),
        .package(url: "https://github.com/nextincrement/simple-asn1-reader-writer.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "1.1.3"),
        //.package(url: "https://github.com/iansampson/Anchor", from: "0.1.2")
        .package(url: "https://github.com/iansampson/Anchor", .branch("main"))
    ],
    targets: [
        .target(
            name: "AppAttest",
            dependencies: [
                "SwiftCBOR",
                .product(name: "Crypto", package: "swift-crypto"),
                "Anchor",
                .product(name: "SimpleASN1Reader", package: "simple-asn1-reader-writer")
            ]
        ),
        .testTarget(
            name: "AppAttestTests",
            dependencies: ["AppAttest"],
            resources: [
                .process("Resources/Attestation.txt")
            ]
        )
    ]
)
