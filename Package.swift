// swift-tools-version:5.0
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
        .package(url: "https://github.com/danger/swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "SwiftChecksDangerPlugin", dependencies: ["Danger"]),
    ],
    swiftLanguageVersions: [.v5]
)
