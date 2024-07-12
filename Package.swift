// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "FCM",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        //Vapor client for Firebase Cloud Messaging
        .library(name: "FCM", targets: ["FCM"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.77.0"),
        .package(url: "https://github.com/vapor/jwt", from: "5.0.0-rc.1"),
    ],
    targets: [
        .target(name: "FCM", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "JWT", package: "jwt"),
        ]),
        .testTarget(name: "FCMTests", dependencies: [
            .target(name: "FCM"),
        ]),
    ]
)
