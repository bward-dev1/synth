// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthMesh",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthMesh", targets: ["SynthMesh"])
    ],
    dependencies: [
        .package(path: "../SynthCore")
    ],
    targets: [
        .target(
            name: "SynthMesh",
            dependencies: [
                .product(name: "SynthCore", package: "SynthCore")
            ],
            path: "Sources/SynthMesh"
        )
    ]
)
