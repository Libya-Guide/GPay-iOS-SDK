// swift-tools-version:5.7
//
//  Package.swift
//  GPay-iOS-SDK
//
//  Created by Basem Elazzabi on 12/6/2025.
//

import PackageDescription

let package = Package(
    name: "GPay_iOS_SDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "GPay_iOS_SDK",
            type: .dynamic, // Ensure dynamic framework for embedding
            targets: ["GPay_iOS_SDK"]),
    ],
    targets: [
        .target(
            name: "GPay_iOS_SDK",
            path: "Sources/GPay_iOS_SDK"
        ),
        .testTarget(
            name: "GPay_iOS_SDKTests",
            dependencies: ["GPay_iOS_SDK"],
            path: "Tests/GPay_iOS_SDKTests"
        )
    ]
)
