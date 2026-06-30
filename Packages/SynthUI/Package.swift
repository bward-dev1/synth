// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthUI", targets: ["SynthUI"])
    ],
    dependencies: [
        .package(path: "../SynthCore"),
        .package(path: "../SynthScripting"),
        .package(path: "../SynthTexture"),
        .package(path: "../SynthMesh"),
        .package(path: "../SynthAudio"),
        .package(path: "../SynthDocs")
    ],
    targets: [
        .target(
            name: "SynthUI",
            dependencies: [
                .product(name: "SynthCore", package: "SynthCore"),
                .product(name: "SynthScripting", package: "SynthScripting"),
                .product(name: "SynthTexture", package: "SynthTexture"),
                .product(name: "SynthMesh", package: "SynthMesh"),
                .product(name: "SynthAudio", package: "SynthAudio"),
                .product(name: "SynthDocs", package: "SynthDocs")
            ],
            path: "Sources/SynthUI"
        )
    ]
)
