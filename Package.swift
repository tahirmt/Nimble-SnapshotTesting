// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Nimble-SnapshotTesting",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "Nimble-SnapshotTesting",
            targets: ["NimbleSnapshotTestingObjc"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 .upToNextMajor(from: "1.10.0")),
        .package(url: "https://github.com/Quick/Nimble.git",
                 .upToNextMajor(from: "12.0.0"))
    ],
    targets: [
        .target(
            name: "Nimble-SnapshotTesting",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "Nimble"
            ],
            path: "Nimble-SnapshotTesting",
            exclude: [
                "Classes/Objc",
            ],
            sources: ["Classes"]
        ),
        .target(
            name: "NimbleSnapshotTestingObjc",
            dependencies: [
                "Nimble-SnapshotTesting"
            ],
            path: "Nimble-SnapshotTesting",
            sources: [
                "Classes/Objc"
            ]
        )
    ]
)
