// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARVideoKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ARVideoKit",
            targets: ["ARVideoKit"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "ARVideoKit",
            dependencies: [],
            path: "ARVideoKit"),
    ]
)
