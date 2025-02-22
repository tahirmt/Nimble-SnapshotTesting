# Nimble-SnapshotTesting

[![CI](https://github.com/tahirmt/Nimble-SnapshotTesting/actions/workflows/ci.yml/badge.svg)](https://github.com/tahirmt/Nimble-SnapshotTesting/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftahirmt%2FNimble-SnapshotTesting%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tahirmt/Nimble-SnapshotTesting)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftahirmt%2FNimble-SnapshotTesting%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tahirmt/Nimble-SnapshotTesting)

A Nimble matcher for https://github.com/pointfreeco/swift-snapshot-testing inspired from the work in https://github.com/ashfurrow/Nimble-Snapshots and https://github.com/Killectro/swift-snapshot-testing-nimble

## Example

The example project exists at `Example-SPM` however it is not necessary. 

## Requirements

Swift 5.9 or later for swift package manager

## Installation

For swift package manager

```
.package(url: "https://github.com/tahirmt/Nimble-SnapshotTesting.git", from: "4.0.0"),

```

## Usage

To use the library with `Nimble` you have two ways

```
let view = UIView()
expect(view).to(haveValidSnapshot(as: .image))
```

or you can even use the `==` syntax

```
let view = UIView()
expect(view) == snapshot(as: .image)
```

## License

Nimble-SnapshotTesting is available under the MIT license. See the LICENSE file for more info.
