// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Valid",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "Valid",
                 targets: ["Valid"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Valid",
                dependencies: [],
                exclude: ["Validator/ValidationRulesBuilder.swift.gyb"]),
        .testTarget(name: "ValidTests",
                    dependencies: ["Valid"]),
    ]
)
