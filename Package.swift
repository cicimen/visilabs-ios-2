// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VisilabsIOSNew",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "VisilabsIOSNew",
            targets: ["VisilabsIOSNew"])
    ],

    targets: [
        .target(
            name: "VisilabsIOSNew",
            path: "Sources",
            exclude: [
                "Info.plist",
            ],
            resources: [
                .process("Sources/Assets"),
            ],
            publicHeadersPath: "include"
        )
    ]
)