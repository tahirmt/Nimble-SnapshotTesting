// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Nimble-SnapshotTesting",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(
            name: "Nimble-SnapshotTesting",
            targets: ["NimbleSnapshotTestingObjc"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 .upToNextMajor(from: "1.10.0")),
        .package(url: "https://github.com/Quick/Nimble.git",
                 .upToNextMajor(from: "14.0.0")),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "Nimble-SnapshotTesting",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "Nimble"
            ]
        ),
        .target(
            name: "NimbleSnapshotTestingObjc",
            dependencies: [
                "Nimble-SnapshotTesting"
            ]
        ),
        .testTarget(
            name: "Nimble-SnapshotTestingTests",
            dependencies: [
                "NimbleSnapshotTestingObjc",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            exclude: [
                "__Snapshots__"
            ]
        )
    ]
)
