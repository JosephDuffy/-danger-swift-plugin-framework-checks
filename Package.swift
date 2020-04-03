// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SwiftChecksDangerPlugin",
    platforms: [
        .macOS(.v10_10),
    ],
    products: [
        .library(name: "SwiftChecksDangerPlugin", type: .dynamic, targets: ["SwiftChecksDangerPlugin"]),
    ],
    dependencies: [
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftChecksDangerPlugin",
            dependencies: [
                .product(name: "Danger", package: "danger-swift")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
