// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Perth",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "PerthCore",
            path: "Sources/Perth",
            exclude: ["main.swift", "Resources"]
        ),
        .executableTarget(
            name: "Perth",
            dependencies: ["PerthCore"],
            path: "Sources/PerthMain",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate",
                              "-Xlinker", "__TEXT",
                              "-Xlinker", "__info_plist",
                              "-Xlinker", "Sources/Perth/Resources/Info.plist"])
            ]
        ),
        .testTarget(
            name: "PerthTests",
            dependencies: ["PerthCore"],
            path: "Tests/PerthTests"
        ),
    ]
)
