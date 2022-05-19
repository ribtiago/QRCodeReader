// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRCodeReader",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "QRCodeReader",
            targets: ["QRCodeReader"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ribtiago/SwiftUIExtras", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "QRCodeReader",
            dependencies: [
                "SwiftUIExtras"
            ])
    ]
)
