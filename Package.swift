// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VidpEngine",
    products: [
        .library(name: "VidpEngine", targets: ["VidpEngine"]),
    ],
    targets: [
        .target(name: "VidpEngine"),
        .testTarget(name: "VidpEngineTests", dependencies: ["VidpEngine"]),
    ]
)
