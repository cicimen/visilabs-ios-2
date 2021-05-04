// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VisilabsIOSNew",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "VisilabsIOSNew",
            targets: ["VisilabsIOSNew"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "VisilabsIOSNew",
            dependencies: []),
        .testTarget(
            name: "VisilabsIOSNewTests",
            dependencies: ["VisilabsIOSNew"]),
    ],
    swiftLanguageVersions: [.v5]
)
