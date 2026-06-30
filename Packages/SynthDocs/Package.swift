// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SynthDocs",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SynthDocs", targets: ["SynthDocs"])
    ],
    targets: [
        .target(
            name: "SynthDocs",
            path: "Sources/SynthDocs"
        )
    ]
)
