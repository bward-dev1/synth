// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthScripting",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthScripting", targets: ["SynthScripting"])
    ],
    dependencies: [
        .package(path: "../SynthCore")
    ],
    targets: [
        .target(
            name: "SynthScripting",
            dependencies: [
                .product(name: "SynthCore", package: "SynthCore")
            ],
            path: "Sources/SynthScripting"
        )
    ]
)
