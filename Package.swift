// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FindFaster",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [.library(name: "FindFaster", targets: ["FindFaster"])],
    targets: [
        .target(name: "FindFaster"),
        .testTarget(name: "FindFasterTests", dependencies: ["FindFaster"]),
    ]
)
