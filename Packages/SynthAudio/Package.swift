// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthAudio",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthAudio", targets: ["SynthAudio"])
    ],
    dependencies: [
        .package(path: "../SynthCore")
    ],
    targets: [
        .target(
            name: "SynthAudio",
            dependencies: [
                .product(name: "SynthCore", package: "SynthCore")
            ],
            path: "Sources/SynthAudio"
        )
    ]
)
