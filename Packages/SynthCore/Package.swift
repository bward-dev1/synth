// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthCore",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthCore", targets: ["SynthCore"])
    ],
    targets: [
        .target(
            name: "SynthCore",
            dependencies: [],
            path: "Sources/SynthCore"
        )
    ]
)
