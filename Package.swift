// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftChecksDangerPlugin",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        .library(name: "SwiftChecksDangerPlugin", type: .dynamic, targets: ["SwiftChecksDangerPlugin"]),
    ],
    dependencies: [
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "3.12.3"),
    ],
    targets: [
        .target(
            name: "SwiftChecksDangerPlugin",
            dependencies: [
                .product(name: "Danger", package: "danger-swift"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
