// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tmdb",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "tmdb",
            targets: ["MovieDB"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/GraphZahl.git", from: "0.1.0-alpha.35"),
        .package(url: "https://github.com/nerdsupremacist/graphzahl-vapor-support.git", from: "0.1.0-alpha.7"),
    ],
    targets: [
        .target(
            name: "MovieDB",
            dependencies: ["GraphZahlVaporSupport", "GraphZahl"]
        ),
    ]
)
