// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthTexture",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthTexture", targets: ["SynthTexture"])
    ],
    dependencies: [
        .package(path: "../SynthCore")
    ],
    targets: [
        .target(
            name: "SynthTexture",
            dependencies: [
                .product(name: "SynthCore", package: "SynthCore")
            ],
            path: "Sources/SynthTexture"
        )
    ]
)
