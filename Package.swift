// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Perth",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Perth",
            path: "Sources/Perth",
            exclude: ["Resources/Info.plist"],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate",
                              "-Xlinker", "__TEXT",
                              "-Xlinker", "__info_plist",
                              "-Xlinker", "Sources/Perth/Resources/Info.plist"])
            ]
        )
    ]
)
